# DrawingManagerおよびDrawingManager_researcher
``` matlab:example.m
dmr=DrawingManager_researcher();
dmr.setFlag("subject",subj);
dmr.setFlag("group","sham");
dmr.setFlag("date",string(today()));
dmr.setFlag("task","motor_exacution");

dmr.figure(1);
dmr.plot(x_data,y_data);
dmr.figure(2);
dmr.sublplot(2,1,1);
dmr.scatter(x_data,y_data);
dmr.sublplot(2,1,2);
dmr.scatter(x_data,y_data);
```
DrawingManagerは描画基本セッティングの管理
DM_researcherはメモ書き機能の追加。

# Remover

## desc
FigureManager_researcherで余計に増えてしまったアノテーションをひっぺがす


## contents

### main.py
本体。現状頭の方でファイル名を指定する。

### filePick.py
使いません
