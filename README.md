# CA Project 7

## Run guide

scenario 1:
```bash
./judge.sh CPU_dual.circ tb_scenario1.v
```

scenario 2:
```bash
./judge.sh CPU_dual.circ tb_scenario2.v
```

scenario 3:
```bash
# Single-path pipline
./judge.sh CPU_single.circ tb_scenario3_single.v

# Dual-path pipeline
./judge.sh CPU_dual.circ tb_scenario3_dual.v
```

fibonacci:
```bash
# Single-path pipline
./judge.sh CPU_single.circ tb_fibo_single.v

# Dual-path pipeline
./judge.sh CPU_dual.circ tb_fibo_dual.v
```

