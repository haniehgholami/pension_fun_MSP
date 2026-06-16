### AMPL Model: Dynamic ALM for Pension Funds (Solvency II & Duration Matching)

# --- SETS ---
set NODES;
set ASSETS;

# --- PARAMETERS ---
param parent {NODES} symbolic;
param is_decision {NODES} binary; 
param prob {NODES};
param rho {NODES, ASSETS};      # Price Return (Capital Gain)
param xi {NODES, ASSETS};       # Income Return (Yield/Dividend)
param liability {NODES};
param asset_duration {ASSETS};  # Duration for each asset type

param Initial_Assets;
param Initial_Liability;
param Target_Surplus;           # Long-term funding target

# Solvency II Risk Charges (ki) - From Slide 10
param k {ASSETS} default 0.20; 

# Weights for Multi-Objective Function (Slide 11)
param w1 := 1.0;   # Weight for Funding Deficit
param w2 := 2.0;   # Weight for Risk Capital Charge
param w3 := 10.0;  # Weight for Sponsor Contributions
param w4 := 5.0;   # Weight for Net DBO Surplus Gap

# --- VARIABLES ---
var x {NODES, ASSETS} >= 0;          # Value held in each asset
var x_plus {NODES, ASSETS} >= 0;     # Amount purchased
var x_minus {NODES, ASSETS} >= 0;    # Amount sold
var z {NODES} >= 0;                  # Cash balance (Liquidity)
var deficit {NODES} >= 0;            # Funding gap
var employer_cont {NODES} >= 0;      # Emergency cash injection
var surplus_gap {NODES} >= 0;        # Distance to Target_Surplus

# --- OBJECTIVE FUNCTION ---
minimize Total_Strategic_Risk:
    sum {n in NODES} prob[n] * (
        w1 * deficit[n]                         # Goal 1: Minimize Deficit
        + w2 * (sum{i in ASSETS} k[i] * x[n,i]) # Goal 2: Risk-Adjusted Return
        + w3 * employer_cont[n]                 # Goal 3: Minimize Sponsor Burden
        + w4 * surplus_gap[n]                   # Goal 4: Achieve Net DBO Target
    );

# --- CONSTRAINTS ---

# 1. Asset Inventory Dynamics (Slide 4)
subject to Inventory_Balance {n in NODES, i in ASSETS: n <> 'root'}:
    x[n,i] = x[parent[n],i] * (1 + rho[n,i]) + x_plus[n,i] - x_minus[n,i];

# 2. Cash Flow & Liquidity Management (Slide 7)
subject to Cash_Balance {n in NODES}:
    z[n] = (if n == 'root' then 0 else z[parent[n]]) 
           + sum{i in ASSETS} (x[if n == 'root' then 'root' else parent[n], i] * xi[n,i]) 
           + sum{i in ASSETS} x_minus[n,i]
           + employer_cont[n] 
           - sum{i in ASSETS} x_plus[n,i]
           - (if n == 'root' then 0 else liability[n]);

# 3. Initial Portfolio Setup
subject to Root_Initial_Assets:
    sum {i in ASSETS} x['root', i] = Initial_Assets;

# 4. Defining Funding Deficit
subject to Funding_Gap_Def {n in NODES}:
    deficit[n] >= liability[n] - (sum{i in ASSETS} x[n,i] + z[n]);

# 5. Strategic Target Gap (Net DBO)
subject to Net_DBO_Target {n in NODES: is_decision[n] = 1}:
    (sum{i in ASSETS} x[n,i] + z[n]) + surplus_gap[n] >= Target_Surplus;

# 6. Diversification Limits (Slide 12)
subject to Asset_Cap {n in NODES, i in ASSETS}:
    x[n,i] <= 0.60 * (sum{j in ASSETS} x[n,j] + z[n]);

# 7. Turnover Control (Slide 12)
subject to Turnover_Limit {n in NODES: n <> 'root' and is_decision[n] = 1}:
    sum{i in ASSETS} (x_plus[n,i] + x_minus[n,i]) <= 0.30 * sum{i in ASSETS} x[parent[n],i];

# 8. Solvency II Capital Buffer (Slide 8)
subject to Solvency_Requirement {n in NODES}:
    sum{i in ASSETS} x[n,i] + z[n] >= liability[n] + sum{i in ASSETS} (k[i] * x[n,i]);

# 9. Portfolio Duration Matching (Slide 3)
subject to Duration_Constraint {n in NODES: is_decision[n] = 1}:
    sum {i in ASSETS} asset_duration[i] * x[n,i] >= 15.0 * sum{j in ASSETS} x[n,j];

# 10. Continuity for Non-Decision Years
subject to No_Trade_Static {n in NODES, i in ASSETS: n <> 'root' and is_decision[n] = 0}:
    x_plus[n,i] = 0 and x_minus[n,i] = 0;