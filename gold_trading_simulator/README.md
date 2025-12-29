# gold_trading_simulator

Flutter-based gold trading simulator featuring live charting, EMA/Stochastic indicators, auto-strategy execution, account simulation, and historical backtesting.

## Key features
- Lightweight Charts rendered in a WebView with frame selection (M1/M5/M15), zoom/pan, countdown timer, and drawing tools overlay.
- OANDA REST and streaming integration for historical candles and live price updates.
- EMA (50/150) and Stochastic oscillator with user-configurable inputs and UI panels.
- Strategy engine gating trade direction via EMAs and %K cross rules, with trade markers on the chart.
- Account simulator with balance/lot/TP/SL controls, auto close logic, and equity tracking.
- Backtest runner over historical ranges with summary metrics and equity curve generation.
- GitHub Actions workflow to build and upload the Android APK artifact.

## Getting started
1. Install Flutter (stable channel) and Android tooling.
2. Run `flutter pub get` to install dependencies.
3. To launch the app: `flutter run`.
4. To build a release APK locally: `flutter build apk`.

## CI build
GitHub Actions workflow `.github/workflows/build.yml` installs Flutter, builds the APK, and uploads it as an artifact.
