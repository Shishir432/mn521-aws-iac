"""Generates docs/architecture.png - AWS architecture for MN521 Part C."""
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

fig, ax = plt.subplots(figsize=(16, 10), dpi=150)
ax.set_xlim(0, 160)
ax.set_ylim(0, 100)
ax.axis("off")

INK = "#232F3E"


def box(x, y, w, h, edge, face="white", ls="-", lw=1.8, r=1.2):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle=f"round,pad=0,rounding_size={r}",
                                linewidth=lw, edgecolor=edge, facecolor=face, linestyle=ls))


def label(x, y, text, size=10, weight="normal", color=INK, ha="left", va="top", style="normal"):
    ax.text(x, y, text, fontsize=size, fontweight=weight, color=color, ha=ha, va=va,
            fontstyle=style, family="DejaVu Sans")


def node(x, y, w, h, title, sub, edge, face):
    box(x, y, w, h, edge, face, lw=1.6, r=0.8)
    label(x + w / 2, y + h - 1.2, title, 10, "bold", ha="center")
    label(x + w / 2, y + h - 4.4, sub, 8.2, ha="center")


def arrow(p1, p2, color=INK, ls="-", text=None, toff=(0, 1.2), rad=0.0, lw=1.8):
    ax.add_patch(FancyArrowPatch(p1, p2, arrowstyle="-|>", mutation_scale=16, color=color,
                                 linewidth=lw, linestyle=ls, connectionstyle=f"arc3,rad={rad}"))
    if text:
        mx, my = (p1[0] + p2[0]) / 2 + toff[0], (p1[1] + p2[1]) / 2 + toff[1]
        ax.text(mx, my, text, fontsize=8.2, color=color, ha="center", va="bottom",
                bbox=dict(boxstyle="round,pad=0.25", fc="white", ec="none"))


# ---------------- Title ----------------
label(80, 99, "MN521 Part C – AWS Infrastructure as Code (Terraform)", 15, "bold", ha="center")
label(80, 95.6, "Region ap-southeast-2 (Sydney) · VPC 10.50.0.0/16 · 2 AZs · Bastion-host access pattern",
      10, ha="center", color="#555")

# ---------------- Left: IaC workflow ----------------
box(1, 8, 30, 84, "#7F8C8D", "#F7F9F9", ls="--", lw=1.2)
label(16, 90.5, "IaC workflow", 11, "bold", ha="center")
node(4, 76, 24, 10, "Engineer workstation", "VS Code · Terraform CLI\nAWS CLI", "#555", "#FFFFFF")
node(4, 60, 24, 11, "Git / GitHub repo", "main branch · commit history\nCI: fmt → init → validate", "#6E5494", "#F3EEF9")
node(4, 44, 24, 11, "Terraform core", "init → fmt/validate → plan\n→ apply → (destroy)", "#7B42BC", "#F1EAFB")
node(4, 28, 24, 11, "Terraform state", "terraform.tfstate (git-ignored)\nS3 + locking for teams", "#7B42BC", "#FFFFFF")
node(4, 12, 24, 11, "AWS provider ~> 5.0", "calls AWS APIs with\nIAM user credentials", "#FF9900", "#FFF6E8")
arrow((16, 76), (16, 71.2), "#6E5494", text="git commit / push", toff=(0, -0.6))
arrow((16, 60), (16, 55.2), "#7B42BC")
arrow((16, 44), (16, 39.2), "#7B42BC")
arrow((16, 28), (16, 23.2), "#7B42BC")
arrow((28.2, 17.5), (37.5, 17.5), "#FF9900", text="API", toff=(0, 0.2))

# ---------------- AWS Cloud / Region ----------------
box(35, 3, 124, 89, INK, "#FFFFFF", lw=2)
label(37, 90.8, "AWS Cloud", 11, "bold")
box(38, 5, 118, 81, "#147EBA", "#FFFFFF", ls="--", lw=1.4)
label(40, 84.8, "Region: ap-southeast-2 (Sydney)", 10, "bold", color="#147EBA")

# VPC
box(41, 7, 112, 70, "#8C4FFF", "#FBF9FF", lw=2)
label(43, 75.8, "VPC  10.50.0.0/16  (mn521-enterprise-dev-vpc)", 10, "bold", color="#8C4FFF")

# Internet gateway on VPC edge
node(122, 72, 24, 9, "Internet Gateway", "igw → 0.0.0.0/0", "#8C4FFF", "#EFE6FF")

# Admin outside
node(122, 87.2, 34, 8, "Administrator (admin_cidr /32)", "SSH key: mn521-…-key.pem", "#555", "#FFFFFF")

# AZ columns
for i, (x, az) in enumerate([(44, "ap-southeast-2a"), (99, "ap-southeast-2b")]):
    box(x, 9, 51, 61, "#147EBA", "none", ls=(0, (4, 3)), lw=1.2)
    label(x + 25.5, 69, f"Availability Zone {az}", 9.5, "bold", color="#147EBA", ha="center")

# Public subnets
box(46, 40, 47, 26, "#248814", "#EEF7EC", lw=1.6)
label(47.5, 64.8, "Public subnet a  10.50.1.0/24", 9.5, "bold", color="#248814")
box(101, 40, 47, 26, "#248814", "#EEF7EC", lw=1.6)
label(102.5, 64.8, "Public subnet b  10.50.2.0/24", 9.5, "bold", color="#248814")
label(102.5, 61.5, "Reserved for HA: second bastion /\nload balancer / NAT", 8.2, color="#555", style="italic")

# Private subnets
box(46, 11, 47, 26, "#147EBA", "#EAF3FA", lw=1.6)
label(47.5, 35.8, "Private subnet a  10.50.11.0/24", 9.5, "bold", color="#147EBA")
box(101, 11, 47, 26, "#147EBA", "#EAF3FA", lw=1.6)
label(102.5, 35.8, "Private subnet b  10.50.12.0/24", 9.5, "bold", color="#147EBA")
label(102.5, 32.5, "Reserved for HA: app/db replicas", 8.2, color="#555", style="italic")

# Bastion in public a (security group outline)
box(48, 43, 22, 15.5, "#DD344C", "none", ls=(0, (3, 2)), lw=1.3, r=0.6)
label(48.8, 58.1, "bastion-sg: SSH from admin", 7.3, color="#DD344C")
node(49.5, 44, 19, 11, "Bastion host", "EC2 t3.micro · AL2023\npublic IP · IMDSv2", "#FF9900", "#FFF6E8")

# Optional NAT
box(73, 44, 18, 11, "#8C4FFF", "#FFFFFF", ls="--", lw=1.3, r=0.8)
label(82, 53.8, "NAT Gateway", 9, "bold", ha="center", color="#8C4FFF")
label(82, 50.5, "optional\nenable_nat_gateway", 7.8, ha="center", color="#8C4FFF", style="italic")

# Private EC2
box(48, 13, 26, 15.5, "#DD344C", "none", ls=(0, (3, 2)), lw=1.3, r=0.6)
label(48.8, 28.1, "private-sg (from bastion)", 7.3, color="#DD344C")
node(50, 14, 21, 11, "Linux server app01", "EC2 t3.micro · AL2023\nno public IP · encrypted gp3", "#FF9900", "#FFF6E8")

# Route tables
node(76, 19, 16, 11, "Private RT", "local only\n(+0.0.0.0/0→NAT)", "#147EBA", "#FFFFFF")
node(129, 43, 17, 10, "Public RT", "0.0.0.0/0 → IGW\nassoc: pub a, b", "#248814", "#FFFFFF")

# Arrows
arrow((139, 87.2), (135, 81.2), "#DD344C", text="SSH 22/tcp", toff=(-9, -1.5))
arrow((122, 74), (66, 55.2), "#DD344C")
arrow((66, 44), (66, 25.2), "#DD344C", text="SSH / ping (jump)", toff=(8, 3.0))
arrow((137.5, 53), (137.5, 72), "#248814", ls="--", lw=1.2)

# Legend
lx, ly = 122, 20
box(lx - 1, ly - 8.5, 33, 15, "#AAA", "#FFFFFF", lw=0.8)
label(lx, ly + 5.8, "Legend", 9, "bold")
for j, (c, t, ls) in enumerate([("#248814", "Public subnet / route", "-"),
                                 ("#147EBA", "Private subnet / route", "-"),
                                 ("#DD344C", "Security group / SSH path", "--"),
                                 ("#8C4FFF", "Optional (not Free Tier)", "--")]):
    yy = ly + 2.2 - j * 2.6
    ax.plot([lx, lx + 4], [yy, yy], color=c, lw=2, ls=ls)
    label(lx + 5, yy + 1, t, 8)

plt.savefig("docs/architecture.png", bbox_inches="tight", facecolor="white")
print("saved")
