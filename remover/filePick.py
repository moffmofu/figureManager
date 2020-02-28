# モジュールのインポート
import os
import tkinter
import tkinter.filedialog as fdl
import tkinter.messagebox as msgb

# ファイル選択ダイアログの表示
def callfileDir
root = tkinter.Tk()
root.withdraw()
fTyp = [("","*.png")]
iDir = os.path.abspath(os.path.dirname(__file__))
msgb.showinfo('○×プログラム','処理ファイルを選択してください！')
file = fdl.askopenfilename(filetypes = fTyp,initialdir = iDir)
return file
# 処理ファイル名の出力
msgb.showinfo('○×プログラム',file)
