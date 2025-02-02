# ザ・ミッション: タクシーの運賃を求めろ！

あなたは、タクシー会社のシステムエンジニアとして、タクシー運賃を計算するプログラムの開発をすることになった。

この会社では、以下のルールにより運賃を算出している。

1. 初乗運賃として、 1.052 km まで 410 円。
2. それ以降の加算運賃として、237 m ごとに 80 円。
3. 時速 10 km 以下の走行時間について、低速運賃として、1 分 30 秒ごとに 80 円。
4. 夜 22 時〜翌 5 時の間、深夜割増料金とする

あなたは、タクシーの走行ログを元に、正しい運賃を計算しなければならない。

## 詳細な仕様

### 入力形式

- 走行ログは、標準入力にヘッダ行無しのスペース文字で区切られた表形式データとして渡される。

  ```plain
  13:50:08.245 0.0
  13:50:11.123 4.0
  13:50:12.125 10.2
  13:50:13.100 8.7
  ```

- 1 行目のレコードは乗車開始時に記録される
- それ以降は、前回記録時から一定の距離を走行した場合、車速が大きく変化した場合などに記録される。記録は時間軸に沿って並べられている
- 乗車終了時に最終レコードが記録される。すなわち、1 行目と最終行との間の運賃を計算することになる
- カラムの区切りは ` ` (半角スペース) 1 文字である。最終行の末尾には必ず改行コードが付与されることを前提として良い。改行コードは`<LF>`である
  - 全てのテストにおいて渡されるデータの最終行の末尾には改行コードが付与されている
  - 最終行 (最終レコードの改行コードの後) をのぞいて、空行は存在しない
- 1 カラム目: 記録時刻
  - `hh:mm:ss.fff` 形式である。規定の桁数に満たない数字は `0` で埋められる
  - 乗車開始後に深夜 24 時を跨いだ場合、 `hh` の値は `00` に戻らずに、 `24` 、 `25` ・・・と表記される
  - その場合も、 `hh` が `99` を超え 3 桁になることはない。それほど長時間を走り続けることなどはできない
- 2 カラム目: 前回記録時からの走行距離 (m)
  - 小数第 1 位 (10cm) 単位で記録される。小数第 1 位が `0` の場合は、 `XX.0` のように表記される
  - 数値の範囲は `0.0` 〜 `99.9` である
  - 1 行目は必ず `0.0` である
- 必ず 2 行 (乗車開始時、終了時) 以上のデータ行が含まれる。総走行距離は `0.1` 以上である。
- 入力の最大行数はたかだか 5 万行であることを前提として良い

### 出力形式

- 正常な入力に対しては、運賃 (円) を標準出力に出力して、終了コード `0` で終了する。末尾の改行の有無は問わない

  ```plain
  1234
  ```

- 仕様に従わない異常な入力に対しては、標準出力には何も出力せずに、終了コード `0` **以外で** 終了する。
- 入力の正常・異常を問わず、(常識的な範囲における) 標準エラー出力の出力内容は問わない。

### 運賃計算の詳細な仕様

- 初乗、加算運賃は以下の方法で計算する
  - 初乗運賃の距離を超えた分の走行距離は加算運賃の距離単位で切り上げる。深夜割増料金が発生しない場合 (以下、通常時間帯)、距離別運賃は下記の表の通りである
  - 走行ログの前回記録時刻、今回記録時刻がともに深夜時間帯 (`00:00:00.000` 〜 `04:59:59.999`、`22:00:00.000` 〜 `23:59.59.999` および `24` 時間ずつ足したバリエーション。区間は閉区間とする) に含まれる場合は、その記録は深夜時間帯の走行として、割増運賃の対象となる。
  - 深夜割増運賃は、深夜時間帯における走行距離が実際の距離の 1.25 倍になっているものとして補正して計算する。
    例えば、深夜 23 時から 850.0 m 乗車した場合の料金を考える。この時の料金は、補正後の走行距離が 1062.5 m = 850 m \* 1.25 であるため、料金は表から 490 円である。
  - 通常・深夜時間帯の切り替えをまたぐ乗車の場合、通常時間帯の走行距離と深夜時間帯の補正後の走行距離とは通算して計算する。時間帯の切り替え時にそれまでの走行距離が清算されたり、初乗り料金が新たに発生したりすることはない。

|                 総走行距離 |   運賃 |
| -------------------------: | -----: |
|    0 m を超え、1052 m 以下 | 410 円 |
| 1052 m を超え、1289 m 以下 | 490 円 |
| 1289 m を超え、1526 m 以下 | 570 円 |
|                        ... |    ... |

- 低速運賃は以下の方法で計算する
  - 速度は、レコードの平均速度 (走行距離を前回記録からの時間で割ったもの) にて算出する
  - 平均速度が 10km 以下の場合は、その時間はずっと 10km 以下で走行したものとして計算し、逆に平均速度が 10km を超える場合は、その時間はずっと 10km を超える速度で走行したものとして計算する。
  - 低速走行時間は通常時間帯では、90 秒単位で切り捨てる。通常時間帯の低速運賃は下記の表の通りである
  - 深夜時間帯の走行 (条件は初乗、加算運賃の時と同じである) は割増運賃の対象となる。
  - 深夜割増運賃は、深夜時間帯における低速走行時間が実際の時間の 1.25 倍になっているものとして補正して計算する。
  - 通常・深夜時間帯の切り替えをまたぐ乗車の場合、通常時間帯と深夜時間帯の低速走行時間は同様に通算して計算する。

|         総低速走行時間 |   運賃 |
| ---------------------: | -----: |
|              90 秒未満 |   0 円 |
|  90 秒以上、180 秒未満 |  80 円 |
| 180 秒以上、270 秒未満 | 160 円 |
|                    ... |    ... |
