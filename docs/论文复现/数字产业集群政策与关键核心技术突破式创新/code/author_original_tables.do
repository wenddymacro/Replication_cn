******----------******
*         表1        *
******----------******

use Benchmark.dta
global control_county "Area Pgdp Population Industrilazion Government Agglomeration"
global control_lag "Area_lag Pgdp_lag Population_lag Industrilazion_lag Government_lag Agglomeration_lag"
reghdfe KeyTech DID, a(id year) vce(r)
reghdfe KeyTech DID $control_county, a(id year) vce(r)
reghdfe KeyTech_w DID $control_county, a(id year) vce(r)
reghdfe KeyTech DID $control_lag, a(id year) vce(r)

******----------******
*         表2        *
******----------******
use Mechanism.dta
global control_county "Area Pgdp Population Industrilazion Government Agglomeration"
reghdfe Cospecialize DID $control_county, a(id year) vce(r)
reghdfe KeyTech Cospecialize DID $control_county, a(id year) vce(r)
reghdfe Diffusion DID $control_county, a(id year) vce(r)
reghdfe KeyTech Diffusion DID $control_county, a(id year ) vce(r)
reghdfe Efficiency DID $control_county, a(id year) vce(r)
reghdfe KeyTech Efficiency DID $control_county, a(id year) vce(r)
******----------******
*         表3        *
******----------******
*注：表3实现结果请按照如下两步进行：
*1)按照如下步骤安装正版软件：
Step1 R 官方下载地址：https://cran.r-project.org/mirrors.html
Step2 选择镜像：根据IP选择适合镜像
Step3 选择下载类型：base
Tips：安装路径中不要包括中文字符，以减少不必要的错误！
Step4 RStudio 官方下载地址：https://posit.co/download/rstudio-desktop/
Tips：请保证是Win10+或MacOS12+正版电脑系统
Step5 Gurobi 官方下载地址：https://www.gurobi.com/academia/academic-program-and-licenses/
Tips：请使用教育机构提供的邮箱地址验证
Step6 从上述官网获取注册号注册激活
*2)按照如下Code在R中进行复现：
install.packages("paths")
library(paths)
data <- read_dta('Mechanism.dta')
m1 <- c("Cospecialize")
m2 <- c("Diffusion")
m3 <- c("Efficiency")
mediators <- list(m1, m2, m3)
formula_m0 <- Breakthrough ~ DID+ Area+ Pgdp+ Population+ Industrilazion+ Government+ Agglomeration + countycode_dummies+year_dummies
formula_m1 <- update(formula_m0,    ~ . + Cospecialize)
formula_m2 <- update(formula_m1,    ~ . + Diffusion)
formula_m3 <- update(formula_m2,    ~ . + Efficiency)
formula_ps <- DID ~  Area+ Pgdp+ Population+ Industrilazion+ Government+ Agg + countycode_dummies+year_dummies
require(gbm)
gbm_m0 <- gbm(formula_m0, data = data, distribution = "bernoulli", interaction.depth = 2)
gbm_m1 <- gbm(formula_m1, data = data, distribution = "bernoulli", interaction.depth = 2)
gbm_m2 <- gbm(formula_m2, data = data, distribution = "bernoulli", interaction.depth = 2)
gbm_m3 <- gbm(formula_m3, data = data, distribution = "bernoulli", interaction.depth = 2)
gbm_ymodels <- list(gbm_m0, gbm_m1, gbm_m2, gbm_m3)
data_paths <- paths(a = "DID", y = "Breakthrough", m = mediators,gbm_ymodels, data = data, nboot = 5)
******----------******
*         表4        *
******----------******
use Heterogeneity.dta
global control_county "Area Pgdp Population Industrilazion Government Agg"
reghdfe KeyTech DID $control_county if YGD==0, a(id year) vce(r)
reghdfe KeyTech DID $control_county if YGD==1, a(id year) vce(r)
reghdfe KeyTech DID $control_county if WB==0, a(id year) vce(r)
reghdfe KeyTech DID $control_county if WB==1, a(id year) vce(r)
reghdfe KeyTech DID $control_county if AI==0, a(id year) vce(r)
reghdfe KeyTech DID $control_county if AI==1, a(id year) vce(r)
******----------******
*         表5        *
******----------******
use Extended.dta
global control_county "Area Pgdp Population Industrilazion Government Agglomeration"
reghdfe KeyTech c.DID##c.SupplyChain $control_county , a(id year) vce(r)
reghdfe KeyTech c.DID##c.InnovationChain $control_county , a(id year) vce(r)
