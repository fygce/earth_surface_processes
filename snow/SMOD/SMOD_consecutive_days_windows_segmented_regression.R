library(segmented)

df <- read.csv("C:/Users/Administrator/Desktop/forR.csv")

# 初始线性模型
lm0 <- lm(Thiel.Sen.slope ~ Window, data = df)

# 分段回归（以 15 作为初始估计）
seg_fit <- segmented(lm0, seg.Z = ~ Window, psi = 15)

# 模型摘要
summary(seg_fit)

# 提取断点
bp <- seg_fit$psi[2]
cat("Estimated breakpoint at window length =", bp, "\n")

# 绘图
plot(df$Window, df$Thiel.Sen.slope,
     pch = 19, xlab = "Window (days)",
     ylab = "Theil–Sen slope", 
     main = "Segmented Regression of SMOD Trend vs. Window Length")

plot(seg_fit, add = TRUE, col = "red")
