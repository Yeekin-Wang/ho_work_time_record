from pathlib import Path
p = Path(r"D:\coding\DevEcoStudioProjects\WorkingTimeRecord\main\src\main\ets\pages\Index.ets")
for enc in ['utf-8','utf-16','utf-16-le','gbk']:
    try:
        text = p.read_text(encoding=enc)
        print('ENC', enc, 'LEN', len(text))
        for no in [84,187,226,280,301,386,392,397,587,1020,1207,1209,1226,1559,1560,1568]:
            lines = text.splitlines()
            if no-1 < len(lines):
                print(no, lines[no-1])
        print('---')
    except Exception as e:
        print('FAIL', enc, e)
