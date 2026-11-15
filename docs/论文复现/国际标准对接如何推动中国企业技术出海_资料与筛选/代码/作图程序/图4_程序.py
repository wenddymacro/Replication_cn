from pathlib import Path
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import font_manager
from matplotlib.lines import Line2D
from matplotlib.ticker import FuncFormatter

# =========================================================
#  参数设置
# =========================================================
DATA_FILE = Path(r"C:\Users\Desktop\图4_数据.dta")

FIGSIZE = (8, 8)
DPI = 600
LABEL_TOP_N = 10
MAX_SHIFT_PT = 28
GAP_PT = 2.0
SPREAD_ITER = 500
INSIDE_LABEL_MIN_SIZE = 150

df = pd.read_stata(DATA_FILE)[
    ["bureau", "sim_firm_w", "firm_pat_sum", "office_pat"]
].dropna().copy()

available_fonts = {f.name for f in font_manager.fontManager.ttflist}
font_candidates = [
    "Microsoft YaHei",
    "SimSun",
    "Noto Sans CJK SC",
    "Noto Sans CJK JP",
    "Arial Unicode MS",
    "DejaVu Sans"
]

font_name = next(
    (font for font in font_candidates if font in available_fonts),
    "DejaVu Sans"
)

plt.rcParams["font.family"] = font_name
plt.rcParams["axes.unicode_minus"] = False


# =========================================================
# 构造气泡和拟合线
# =========================================================
df["top"] = (
    df["office_pat"].rank(method="first", ascending=False)
    <= LABEL_TOP_N
)

df["bubble_size"] = (
    65
    + 1000
    * np.sqrt(df["office_pat"] / df["office_pat"].max())
)

# 对数拟合：ln(Y) = a + bX
b, a = np.polyfit(
    df["sim_firm_w"],
    np.log(df["firm_pat_sum"]),
    1
)

x_line = np.linspace(
    df["sim_firm_w"].min(),
    df["sim_firm_w"].max(),
    300
)

y_line = np.exp(a + b * x_line)

def spread_bubbles(
    original_points,
    radii,
    max_shift=28,
    gap=2.0,
    iterations=500
):
    positions = original_points.copy().astype(float)
    n = len(positions)
    for i in range(n):
        angle = 2 * np.pi * i / max(n, 1)
        positions[i] += np.array([
            np.cos(angle),
            np.sin(angle)
        ]) * 0.15

    for _ in range(iterations):
        movement = np.zeros_like(positions)

        for i in range(n):
            for j in range(i + 1, n):
                difference = positions[j] - positions[i]
                distance = np.linalg.norm(difference)

                if distance < 1e-9:
                    angle = 2 * np.pi * (i + j + 1) / (n + 1)
                    direction = np.array([
                        np.cos(angle),
                        np.sin(angle)
                    ])
                    distance = 1e-9
                else:
                    direction = difference / distance

                required_distance = radii[i] + radii[j] + gap

                if distance < required_distance:
                    overlap = required_distance - distance

                    movement[i] -= direction * overlap * 0.50
                    movement[j] += direction * overlap * 0.50


        movement += (original_points - positions) * 0.035

        positions += movement * 0.45

        shifts = positions - original_points
        shift_length = np.linalg.norm(shifts, axis=1)

        too_far = shift_length > max_shift

        if np.any(too_far):
            shifts[too_far] *= (
                max_shift / shift_length[too_far]
            )[:, None]

            positions[too_far] = (
                original_points[too_far]
                + shifts[too_far]
            )

    return positions

fig, ax = plt.subplots(figsize=FIGSIZE)

other = df.loc[~df["top"]].copy()
top = df.loc[df["top"]].copy()

# 普通专利局：白色空心气泡
ax.scatter(
    other["sim_firm_w"],
    other["firm_pat_sum"],
    s=other["bubble_size"],
    facecolors="white",
    edgecolors="black",
    linewidths=1.0,
    zorder=2
)

# 黑色拟合线
ax.plot(
    x_line,
    y_line,
    color="black",
    linewidth=2.4,
    zorder=1
)

# =========================================================
# 坐标轴设置
# =========================================================
ax.set_yscale("log")

ax.set_ylim(
    df["firm_pat_sum"].min() * 0.65,
    df["firm_pat_sum"].max() * 2.40
)

ax.set_xlim(
    df["sim_firm_w"].min() - 0.10,
    df["sim_firm_w"].max() + 0.10
)

fig.canvas.draw()

pixels_per_point = fig.dpi / 72.0

original_pixels = ax.transData.transform(
    np.column_stack([
        top["sim_firm_w"],
        top["firm_pat_sum"]
    ])
)

original_points = original_pixels / pixels_per_point
bubble_radii = np.sqrt(
    top["bubble_size"].to_numpy() / np.pi
)

spread_points = spread_bubbles(
    original_points=original_points,
    radii=bubble_radii,
    max_shift=MAX_SHIFT_PT,
    gap=GAP_PT,
    iterations=SPREAD_ITER
)

spread_pixels = spread_points * pixels_per_point

spread_data = ax.transData.inverted().transform(
    spread_pixels
)

top["x_show"] = spread_data[:, 0]
top["y_show"] = spread_data[:, 1]


# =========================================================
# 绘图
# =========================================================
ax.scatter(
    top["x_show"],
    top["y_show"],
    s=top["bubble_size"],
    facecolors="0.45",
    edgecolors="black",
    linewidths=1.4,
    zorder=3
)

outside_label_offsets = {
    "DE": (-20, 10),
    "CA": (20, 4),
    "RU": (20, -12),
    "BR": (-18, -13),
    "AU": (-20, -14),
    "ES": (18, -15)
}

for _, row in top.iterrows():

    if row["bubble_size"] >= INSIDE_LABEL_MIN_SIZE:
        ax.text(
            row["x_show"],
            row["y_show"],
            row["bureau"],
            ha="center",
            va="center",
            fontsize=11,
            fontweight="bold",
            color="white",
            zorder=4
        )

    else:
        dx, dy = outside_label_offsets.get(
            row["bureau"],
            (12, 8)
        )

        ax.annotate(
            row["bureau"],
            xy=(row["x_show"], row["y_show"]),
            xytext=(dx, dy),
            textcoords="offset points",
            ha="center",
            va="center",
            fontsize=10.5,
            fontweight="bold",
            color="black",
            bbox=dict(
                boxstyle="round,pad=0.08",
                facecolor="white",
                edgecolor="none",
                alpha=0.95
            ),
            arrowprops=dict(
                arrowstyle="-",
                color="black",
                linewidth=0.75,
                shrinkA=1,
                shrinkB=4
            ),
            zorder=4
        )

ax.set_xlabel(
    "企业国际标准技术对接强度（SIM）",
    fontsize=16,
    fontweight="bold",
    labelpad=10
)

ax.set_ylabel(
    "企业海外专利申请总量（项）",
    fontsize=16,
    fontweight="bold",
    labelpad=10
)

ax.tick_params(
    axis="both",
    which="major",
    labelsize=13.5,
    width=1.2,
    length=5
)

ax.yaxis.set_major_formatter(
    FuncFormatter(lambda x, pos: f"{int(x):,}")
)

ax.grid(
    axis="y",
    which="major",
    linestyle="--",
    linewidth=0.8,
    color="0.82"
)

ax.grid(axis="x", visible=False)

for spine in ax.spines.values():
    spine.set_linewidth(1.2)
    spine.set_color("black")

legend_items = [
    Line2D(
        [0], [0],
        marker="o",
        linestyle="none",
        markerfacecolor="0.45",
        markeredgecolor="black",
        markersize=10,
        label="申请量前10位专利局"
    ),
    Line2D(
        [0], [0],
        marker="o",
        linestyle="none",
        markerfacecolor="white",
        markeredgecolor="black",
        markersize=10,
        label="其他专利局"
    ),
    Line2D(
        [0], [0],
        color="black",
        linewidth=2.4,
        label="对数拟合线"
    )
]

ax.legend(
    handles=legend_items,
    loc="lower right",
    frameon=False,
    fontsize=11.5,
    handlelength=2.4
)

fig.subplots_adjust(
    left=0.17,
    right=0.98,
    bottom=0.14,
    top=0.98
)

fig.savefig(
    "图4_企业气泡图.png",
    dpi=DPI,
    facecolor="white"
)

plt.show()
