from pathlib import Path
p = Path(r"D:\coding\DevEcoStudioProjects\WorkingTimeRecord\main\src\main\ets\pages\Index.ets")
lines = p.read_text(encoding="utf-8").splitlines()
for start, end in [(830,930),(1180,1265),(1298,1398)]:
    print(f"--- {start+1}-{end+1} ---")
    for i in range(start, min(end + 1, len(lines))):
        print(f"{i+1}: {lines[i]}")
