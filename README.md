# Multi-Stage Stochastic Optimization for Pension Fund ALM

## Overview

This project focuses on Asset-Liability Management (ALM) for a pension fund using a multi-stage stochastic optimization framework. The goal is to determine optimal asset allocation over a 20-year horizon under uncertainty in financial markets, while ensuring that future liabilities are met and solvency is maintained.

## Repository Structure

The repository consists of three main components:

* `pension-fund-msp.ipynb`
  Python notebook (Google Colab) used for simulation, scenario analysis, and visualization of results such as funding ratio evolution and allocation paths.

* `pension.mod`
  AMPL model file containing the mathematical formulation, including the objective function, constraints, and stochastic structure.

* `pension_final.dat`
  Scenario tree data file with simulated asset returns and economic variables across multiple stages, including probabilities and return paths.

## Methodology

### Asset Allocation

The model allocates capital across a diversified set of asset classes with different maturities and risk profiles, including:

* Short-term instruments (Euro 3M)
* Government bonds (1–3y, 3–5y, 5–7y, 7–10y, 10y+)
* Inflation-linked bonds (TIPS)
* Corporate bonds (IG and HY)
* Equities
* Real estate

### Scenario Modeling

Uncertainty is represented through a multi-stage scenario tree over a 20-year horizon. Each node captures possible realizations of asset returns and cash flows, leading to a large scenario space (11,130+ nodes).

### ALM Framework

The model tracks the evolution of:

* Asset values
* Liability cash flows
* Contribution inflows
* Funding ratio (Assets / Liabilities)

Solvency is evaluated across all scenarios, with particular focus on the probability of falling below the 100% funding threshold at key time points (Years 1, 2, 3, 5, 10, and 20).

### Optimization Objective

The objective is to maximize long-term financial stability while minimizing the risk of underfunding, under stochastic market conditions.

## Results

* The model generates dynamic allocation strategies that adjust over time depending on scenario evolution.
* The funding ratio remains stable in most simulated paths, with risk concentrated in extreme downside scenarios.
* Equity and higher-yield assets contribute to return enhancement, while bonds provide stability and liability matching.

## Technical Stack

* Python (NumPy, Matplotlib)
* AMPL (Mathematical Optimization Modeling)
* Scenario Simulation & Stochastic Programming

## Files in Repository

```text id="alm_repo"
├── pension-fund-msp.ipynb
├── ppension.mod
├── pension_final.dat
└── README.md
```

## Author

Hanieh Gholami Ghalhari
MSc in Quantitative Finance and Insurance
University of Bergamo
