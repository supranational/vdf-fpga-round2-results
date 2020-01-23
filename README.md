# VDF Alliance FPGA Contest Round 2 Results

**Congratulations to Eric Pearson for his winning entry with 25.2 ns/sq latency!!**

This repository contains the results and designs submitted for round 2 of the FPGA competition. See [FPGA Contest Wiki](https://supranational.atlassian.net/wiki/spaces/VA/pages/36569208/FPGA+Contest) for more information about the contest.

The final round for lowest latency design using an alternative representation closes at the end of January. 

## Results

The following designs were submitted and are available in this repository. The submission_form.txt file provides information from the contestants about their design. 

Designs were evaluated for performance as follows:
  * Run hardware emulation to test basic functionality
  * Synthesis using the provided scripts
  * Run for 2^33 iterations on AWS F1 and check for correctness and performance.

Team Name | Directory | Expected | Actual
----------|-----------|----------|-------
Eric Pearson | eric_pearson-1 | 27 ns/sq | 27 ns/sq
Eric Pearson | eric_pearson-2 | 25.2 ns/sq | 25.2 ns/sq
Geriatric Guys with Gates | geriatric_guys_with_gates | 26.4 ns/sq | 26.4 ns/sq
xjtu_asic | xjtu_asic | 30.8 ns/sq | DRC check reported illegal clocks
Ruslan | ruslan | 28.4 ns/sq | Did not meet timing in synthesis
Tulpar | tulpar | various | Not a finished design but promising projections from high level synthesis
