import csv
import json
import math
from pathlib import Path
import sys

root=Path(sys.argv[1])
out=root/"output"
paper="cie123367"
title="税收优惠靶向供给与资本要素流动——来自税务服务专员制度的证据"
primary={"T1_1","T1_4","T2_1","T2_3"}
secondary={"T1_2","T1_3","T2_2","T2_4","T4_3","T4_4","T4_5","T4_6","T6_1","T6_3","T6_5","T8_1","T8_2","T8_3","T8_4"}
extra={"T4_1","T4_2"}
allowed=primary|secondary|extra
models=list(csv.DictReader((root/"code"/"models.csv").open(encoding="utf-8-sig")))
published={row["spec"]:row for row in csv.DictReader((root/"code"/"printed.csv").open(encoding="utf-8-sig"))}
results=[]
audit_path=out/"csa_full_support_audit.csv"
support=list(csv.DictReader(audit_path.open(encoding="utf-8"))) if audit_path.exists() else []
screen={"paper_id":paper,"journal":"cie","year":2026,"issue":7,"title":title,
        "screened_from":"article_text+package","screen_date":"2026-11-24","staggered_design":True,
        "eligible_design":True,"near_miss":False,"near_miss_controls_only":True,
        "main_or_robustness":"main","policy_or_event":"税务服务专员制度按城市推进",
        "unit":"母公司×子公司所在城市；表8为母公司","assignment_unit":"城市对；表8使用母公司处理指标",
        "time_unit":"year","data_access":"public","package_status":"data_and_code",
        "software":"Stata","reports_modern_estimator":False,"estimators_reported":["twfe_static","twfe_event"],
        "eligible_specs":[],"near_miss_controls_only_specs":[],"additional_sensitivity_specs":[],
        "ineligible_specs":[],"appendix_specs":[{"location":"附图3","spec_ids":["F3_1","F3_2","F3_3"]},
          {"location":"附表1–3","scope":"描述统计、稳健性及其他政策控制"}]}
def write_json(path,obj):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(json.dumps(obj,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
for m in models:
    key=m["spec"]
    if not key.startswith("T"):
        continue
    table,column=key[1:].split("_")
    location=f"表{table} 第({column})列"
    if key not in allowed:
        screen["ineligible_specs"].append(dict(spec_id=key,location=location,reason="处理与分组、机制指标或税收优惠变量的交互项"))
        continue
    grp="main" if key in primary else "secondary" if key in secondary else "sensitivity"
    rhs=m["rhs"].split(" + ")
    controls=rhs[1:]
    xt=[] if m["data"]=="2" else ["id","prov_son"] if key=="T1_4" else ["prov","prov_son"]
    p=published[key]
    result_name=f"modern_{key}.csv" if m["data"]=="2" else f"refined_{key}.csv"
    result=next(csv.DictReader((out/result_name).open(encoding="utf-8")))
    assert int(result["n"])==int(p["n"]),key
    assert round(float(result["twfe_raw"]),4)==float(p["coef"]),key
    assert result["twfe"] and result["bjs"],key
    if m["data"]=="1":
        assert result.get("neg_rows_tolerance") is not None,key
        if key=="T4_1" and not result.get("bjs_se"):
            f=out/"T4_1_bjs_did2s.csv"
            if f.exists():
                retry=next(csv.DictReader(f.open(encoding="utf-8")))
                assert abs(float(retry["est"])-float(result["bjs"]))<1e-8
                result["bjs_se"]=retry["se"]
                result["bjs_note"]+="; did2s supplies marginal SE"
        assert result.get("bjs_se") or key in extra,key
        if key!="T1_4":
            assert result.get("csa_overlap") and result.get("csa_overlap_se"),key
            assert float(result["csa_overlap_se"])<0.3,key
        status="province_pair_overlap_only" if key!="T1_4" else "skipped_firm_time_FE_many_levels"
        if key=="T1_1":
            status="default_full_sample_failed_overlap_estimate_reported_separately"
    else:
        assert result.get("csa") and result.get("csa_se") and result.get("bjs_se"),key
        status="project_did"
        variance=float(result["bsd_twfe"])**2+float(result["bsd_bjs"])**2-2*float(result["cov_twfe_bjs"])
        difference=float(result["bjs"])-float(result["twfe"])
        result["diff_bjs_se"]=math.sqrt(variance)
        result["diff_bjs_p"]=math.erfc(abs(difference)/math.sqrt(2*variance))
    checks=[cell for cell in support if cell["spec_id"]==key]
    if checks:
        result["csa_additive_candidates"]=len(checks)
        result["csa_additive_province_supported"]=sum(
            cell["province_support_base"]=="TRUE" and cell["province_support_post"]=="TRUE"
            and int(cell["treated_pre"])>0 and int(cell["treated_post"])>0 for cell in checks)
    for method in ("reg","rank"):
        candidate=out/f"anchored_{method}_{key}.csv"
        if candidate.exists():
            diagnostic=next(csv.DictReader(candidate.open(encoding="utf-8")))
            if diagnostic["csa"] and diagnostic["csa_se"]:
                result["csa_additive"]=diagnostic["csa"]
                result["csa_additive_se"]=diagnostic["csa_se"]
                result["csa_additive_cells_estimated"]=diagnostic["supported"]
                result["csa_additive_method"]=method
                status="additive_supported_cells_plus_province_pair_overlap"
                break
    result["project_group"]=grp
    result["csa_status"]=status
    result["joint_inference"]=("999_draw_cluster_score_multiplier" if m["data"]=="1"
                               else "999_draw_Bayesian_refits_TWFE_BJS")
    if key=="T4_1":
        result["joint_inference"]="999_draw_cluster_score_multiplier_CSA_only"
    results.append(result)
    notes=[]
    if m["data"]=="1":
        notes.append("来自作者样本。以事件期指标反推的首治期优先，逐行核对二元处理状态。")
    else:
        notes.append("以企业首次观察到处理的年份作为首治期，逐行核对二元处理状态。")
    if key in extra:
        notes.append("deep 在大量面板单位内变化，按时间变化的结果相关分组另作敏感性估计。")
    if key=="T1_2":
        notes.append("三项基期城市指标乘时间趋势，原式作为时变控制进入二级。")
    if key=="T1_4":
        notes.append("母公司类别超过 CSA 项目阈值，保留原式 TWFE 与 BJS。")
    folder={"main":"specs","secondary":"specs_controls","sensitivity":"specs_sensitivity"}[grp]
    spec=dict(paper_id=paper,spec_id=key,journal="cie",
              data_path=f"$CIE_RAW/model_data/{paper}__{key}.rds",
              id_var="panel",time_var="year",y_var=m["y"],gvar="g0",cluster_var=m["cluster"],
              xt_vars=xt,controls=controls,static_or_event="static",
              published_coef=float(p["coef"]),published_se=float(p["se"]),published_n=int(p["n"]),
              published_source=location,table=table,column=column,
              preferred=key=="T1_3",in_abstract_intro=table in {"1","2","8"},
              reports_modern_estimator=False,software="Stata",replication_status="exact",
              original_sample_filter=m["subset"],original_fixed_effects=m["fixed"],
              data_preparation="modern_refined.R with CIE_EXPORT_SPEC set to spec_id",
              notes=" ".join(notes))
    write_json(root/"data"/folder/f"{paper}__{key}.json",spec)
    subset_key={"main":"eligible_specs","secondary":"near_miss_controls_only_specs",
                "sensitivity":"additional_sensitivity_specs"}[grp]
    screen[subset_key].append(dict(spec_id=key,location=location,outcome=m["y"],clustering=m["cluster"],
        outcome_transform="作者分析数据的现成变量",treatment_definition=rhs[0],fixed_effects=m["fixed"],
        xt_vars=xt,controls=controls,coef=float(p["coef"]),se=float(p["se"]),n_obs=int(p["n"]),notes=" ".join(notes)))
screen["n_eligible_specs"]=len(screen["eligible_specs"])
screen["priority"]=1
write_json(root/"data"/"screening"/"by_paper"/f"{paper}.json",screen)
assert len(results)==21
fields=list(dict.fromkeys(k for row in results for k in row))
with (out/"现代DID汇总.csv").open("w",encoding="utf-8-sig",newline="") as f:
    writer=csv.DictWriter(f,fieldnames=fields)
    writer.writeheader()
    writer.writerows(results)
print("Archived",len(primary),len(secondary),len(extra))



