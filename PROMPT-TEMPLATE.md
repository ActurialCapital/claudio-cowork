# The One Prompt Template

## Your Go-To Prompt (use this for 80%+ of tasks)

```
I want to [TASK] to [SUCCESS CRITERIA]. First, explore my CLAUDE COWORK folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.
```

## Examples by Domain

### Systematic Equities
```
I want to build a cross-sectional momentum factor model that ranks US large caps by 12-1 month returns and tests 1-month forward performance. Include transaction cost assumptions and out-of-sample validation. First, explore my CLAUDE COWORK folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.
```

### Crypto Strategy
```
I want to backtest a funding rate arbitrage strategy across BTC perps on Binance and Bybit. Account for gas, slippage, and funding payment timing. First, explore my CLAUDE COWORK folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.
```

### Macro / Multi-Asset
```
I want to build a macro regime detection model using yield curve shape, credit spreads, and equity vol to classify risk-on/risk-off environments. First, explore my CLAUDE COWORK folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.
```

### Data Pipeline
```
I want to build a real-time data pipeline that ingests exchange WebSocket feeds, normalizes order book snapshots, and stores them in TimescaleDB with sub-second latency. First, explore my CLAUDE COWORK folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.
```

### Full-Stack Feature
```
I want to build a portfolio risk dashboard with React frontend and FastAPI backend that shows live P&L, VaR, sector exposure, and drawdown charts. First, explore my CLAUDE COWORK folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.
```

### ML Model
```
I want to train a gradient boosted model to predict next-day realized volatility using intraday microstructure features. Include walk-forward validation and feature importance analysis. First, explore my CLAUDE COWORK folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.
```

### Portfolio Analysis
```
I want to decompose my portfolio returns by factor exposure (market, size, value, momentum, quality) and identify unintended bets. First, explore my CLAUDE COWORK folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.
```

### Client Deliverable
```
I want to write a strategy tearsheet for [strategy name] showing performance, risk metrics, factor exposures, and capacity estimate. Format as a clean PDF. First, explore my CLAUDE COWORK folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.
```

## Mac Text Replacement Shortcut
1. Open **System Settings → Keyboard → Text Replacements** (or search "Text Replacement")
2. Click "+"
3. **Replace:** `/prompt`
4. **With:** `I want to [TASK] to [SUCCESS CRITERIA]. First, explore my CLAUDE COWORK folder. Then, ask me questions using the AskUserQuestion tool. I want to refine the approach with you before you execute.`

Now typing `/prompt` anywhere on your Mac expands to the full template. Fill in [TASK] and [SUCCESS CRITERIA].
