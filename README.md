## 自作MVCフレームワークを使って掲示板を作ろう

### まえがき
いきなりPHPのフレームワークから入ると、どこで何をしているのかのイメージがつかないと思うので、実際に作ってみましょうというのが今回の趣旨です。  
  
今回作るものはMVCフレームワークでよくあるフロントコントローラー式の構成です。このあたりの単語をググったりしながら自力で作ってみましょう。写経は意味がないので自分で考えて作りましょう。  
  
環境構築後にURLにアクセスするとindex.phpが読み込まれます。これが全ての処理の起点となるファイルになるので、こちらに続きを実装していきます。フレームワークは1度で全部を解釈しようとすると難しいですが、フレームワークを構成する1つ1つのパーツは大した内容ではありません。  
今回パーツを1つ1つ作ることでPHPに慣れていきましょう。  

### 環境構築手順
※ 予めDockerをインストールしておいて下さい

課題用のリポジトリのURL  
https://github.com/Kate-AC/php-practice
  
上記のURLからclone後、以下のコマンドを実行してください。  
```
$ make build
$ make run
```

http://localhost:23380/ にアクセスし、「Hello world !」が出ていれば完了

これをベースに作っていきます。

## 1. Autoloaderを作ろう
PHPで書かれたファイル及びそこに定義されているclassは、該当のファイルを require または include しないと実行できません。なのでまずPHPに「ここにファイルがありますよ」と教えてあげる必要があります。PHPが知っているファイルの中に対象のclassあれば読み込んでくれます。  
```php
<?php declare(strict_types=1);

require('./app/hoge/Auth.php'); // (2)

use App\\Hoge\\Auth; // (1)

$auth = new Auth(); // (3)
```
PHPのファイルの中で、他のPHPのファイルを呼ぶにはuse(1)をして「このクラスをこのファイル内で使用します」と宣言する必要があります。
事前に(2)でrequireされたファイルの中に対象のclassがあれば、PHP側は(3)の new Auth() という記述を解釈することができます。  
しかし、上記の例だと、ファイルを新しく作る度に(2)の行を追加する必要があります。ファイルが1つ2つであれば問題ありませんが、これが10ファイル100ファイルとなると「このファイルにはこのファイルが必要で・・・」などと考えながら開発する必要があり、それは現実的ではありません。  
殆どのフレームワークにはディレクトリを再帰的に読み込んで、自動でrequireをしておいてくれる仕組みが存在します。  
それがautoloaderです。  
自動で読み込んでもらうためには、ファイルや命名についてのルールをあらかじめ考える必要があります。  

### 【この章でググるとよいワード】

namespace/名前空間  
str_replace/preg_replace  

```
【フィードバック】
オートローダーという仕組みをそもそも知らなかったので、まずはその概念の理解。
オートローダー関数の理解。
名前空間の理解→名前空間とディレクトリの名前は一緒にしておくと分かりやすい。
str_replace関数は今後もよく使う。
PHPのファイル名の先頭は大文字。
クラス名はファイル名と同じにする。
```

## 2. UrlParserを作ろう
MVCフレームワークで特定のURLにアクセスした際に行うことはControllerの選択です。  
例えば/admin/material/create といったパスの場合、`/[ディレクトリ名]/[コントローラー名]/[メソッド名]`という構造になっているパターンが多いです。  
以下はよくあるURLの例です。  
```
/hoge/fuga/piyo/user/list
/hoge_fuga/user_material/delete?id=99
/creator/show/99
```
この場合どれがコントローラーで、どれがメソッドで、どれがパラメータなのかを判断する必要があります。  
それを解析するのがUrlParserです。  
自作フレームワークなので、ルールは自分で決めて構いません。  
また、PHPでは基本的にメソッド名はlower camel case、クラス名はupper camel caseであることが多いです。  

### 【この章でググるとよいワード】
explode/strstr  
$_SERVER  

```
【フィードバック】
$_SERVER変数がとても便利
explode関数は今後もよく使う
ディレクトリがない場合、1つある場合、2つある場合などのそれぞれに対応させるのが難しかった。
対応できるようになったのは不便であることに気づいた後半。
```

## 3. Dispatcherを作ろう
アクセスしたURLに対応したクラスメソッドを実行するのがDispatcherです。  
コントローラーによくあるbefore filterやafter filter等の仕組みを作りたい場合も、このタイミングで実行できます。  
また、どのURLからどのユーザーがアクセスした等のリクエスト情報をコントローラに渡したい場合もここで渡すことができます。  
Railsにはroutes.rbというURLとControllerを結びつけるファイルがありますが、そのURLを元に実際にControllerのメソッドを呼ぶ処理がDispatcherの仕事となります。

```
【フィードバック】
思ったよりルーティングのルールの自由度が高かったのでrails風のルールにした
新しいインスタンス作成時の名前に変数が使えることを学んだ
```

## 4. Controllerを作ろう
Controllerと言っても実態は単なるクラスです。ここでModelからデータを取得してViewにデータを渡すことになります。  
ここまで作って実際にURLにアクセスした際に、URLに紐づいたControllerのメソッドを実行できればOKです。

```
【フィードバック】
まさにコントローラーといってもただのクラスでPHPに特別なコントローラーの関数などが用意されている訳ではなかった。
ただ自分でクラスにコントローラーという名前をつけただけ。
```

## 5. Templateを作ろう
ここではhtml内でPHPのコードを展開できるようにしたものをTemplateとして扱います。MVCフレームワークのVにあたる部分です。  
{{ $変数 }} といったテンプレート独自のルールをここで作ります。  
ここではルールを決めるだけでいいです。  
```
<div>{{ $hoge }}</div>
{% if (99 === $hoge): %}
  <div>Hello</div>
{% endif; %}
```
↓ PHPで出力後
```
<div><?php echo $hoge ?></div>
<?php if (99 === $hoge): ?>
  <div>Hello</div>
<?php endif; ?>
```

```
【フィードバック】
独自のルールの場合当然エディターはその独自ルールを認識してくれず、ハイライトしてくれないのでやや不便。
```

## 6. Rendererを作ろう
Controllerで指定したテンプレート名と渡したい変数を受け取って実際にブラウザに表示させるためのクラスがRendererです。  
テンプレート内の独自構文を読み取ってPHPが解釈できるコードに変換するなどの処理もこの辺りで行うことができます。  
str_replace/preg_match/preg_replace/vsprintfといった関数を駆使すれば実現できるでしょう。  
まずは5章で作ったテンプレートに渡された変数を展開できるようにしてみましょう。  

### 【この章でググるとよいワード】
ob_start/ob_get_contents等のob系の関数  
変数に入れた文字列を変数として展開する方法について  
変数展開時のPHPのスコープについて  

```
【フィードバック】
Viewに変数を複数渡すやり方をどうするか悩んだ→extract関数を使用した。
extractを使わない場合${$変数名}を使えばできる
requireをした段階でブラウザにHTMLは表示されてしまうのでrequireの前にテンプレートをPHPの構文に変換する必要があった。
あるいはobなどを使ってブラウザにHTMLが即出力されるのを防ぐやり方もあった。
```

## 7. ORMを作ろう（準備）
ORM(オブジェクトリレーショナルマッピング)はSQLで取得したDBのデータを実体となるクラスにマッピングして、アプリケーション側で扱いやすくする手法です。  
この実体となるクラスや、ここではSQLを発行するクラスを総括してModelと呼ぶことにします。  
この項はORMを作るにあたり、必要なものを準備しましょう。  
### (1) SequelProをインストールする
- MySQLクライアントです。ググったら出てくるので入れましょう。
### (2) SequelProでphp-practice環境のMySQLに接続
- docker-compose.ymlに接続情報が書いています
### (3) DBを作成し、Userテーブルを作る
- 実際テーブルは何でもいいですが、今回はUserテーブルを例にORMを作ります。
- カラムはこのあたりがあればいいです
```
id(int/PK)
name(varchar)
email(varchar)
created_at(datetime)
updated_at(datetime)
```
### (4) Userテーブルに適当なデータを入れる
- 3件くらいあればとりあえずOKです
### (5) SELECT/UPDATE/INSERT/DELETE文を書けるように練習しよう
- これらのSQLをPHPのコード上で実行するためのORMとなります

```
【フィードバック】
SequelProもDockerのMySQLも使ったことがあったのでスムーズにできた。
Docker内と外でポートが変わるのに少し躓いた。
クエリを初めて書いた。
```

## 8. DbConnectorを作ろう
DBにSQLを発行するには、PHPの組み込み関数であるPDOを利用します。DBへの接続、クエリの実行はこのクラスで行います。  
ここではPDOをラッピングするようなクラスを作り、SELECT文を発行してデータを取得できるところまで確認できればOKです。  

```
### 【フィードバック】
メンバ変数にPDOのインスタンスを入れておくと以降モデルクラスを呼び出せばPDOが使えるようになった。
メンバ変数の値を返すだけのメソッドが便利だった。
```

## 9. QueryBuilerを作ろう
普段SQLを書くときは`SELECT hoge FROM fuga WHERE id = 99`のように書きますが、これをPHPで記述できるように落とし込んだものがQueryBuilderです。  
例を見てみましょう。
```php
$queryBuilder->select('id', 'name')->where('id', '=', 99)->exec();
```
このように→でメソッドをつなげていくことをメソッドチェーンと呼びます。  
QueryBuilderは引数で渡された値を保持し、exec等が呼ばれた際に`SELECT hoge FROM fuga WHERE id = 99`といったSQL文字列を生成し、DbConnectorを経由してDBに対してクエリを実行します。
ただし、複雑なクエリを発行できるようにすると無限に時間がかかるので、最低限のクエリが発行できるように対応すればいいです。  
具体的には`SELECT/CREATE/DELETE/UPDATE/INSERT/JOIN/WHERE`辺りができれば問題ありません。  
全ての項の中で一番難易度が高いと思います。

### 【この章でググるとよいワード】
PDOStatement::setFetchMode

```
【フィードバック】
メソッドチェーンが難しそうだったが実装自体はシンプルだった。
静的メソッドにすることによって呼び出しの記述が綺麗になったが、$thisが使えなくなるためコードの難易度が上がった。
クエリビルダーの中に新しくクエリビルダーインスタンスを作りややこしくなった。
static変数の挙動が難しい。
```

## 10. Modelを作ろう
実際のテーブルと対になるclassを作ります。  
Railsでよくある`find(1)`や`find_by(name: "hoge")`などのメソッドは（今回は）このモデルに定義します。

```
【フィードバック】
QBを継承すればnew QueryBuilderとしなくても呼べた。
get_called_class()が凄く便利。継承と相性が良い。
モデルにテーブル名やカラムを書いておくことでQBから操作しやすくした(クエリを作る際に必要になるため)
```

## 11. Mapperを作ろう
DbConnectorでSELECTクエリを投げた後に返ってきた結果を実クラスにマッピングするのがMapperです。  
9章の時点では、結果は配列で取得されましたが最終的には10章で作ったモデルにデータを入れた状態で取得するのが目標です。  
- 取得イメージ
```php
$result = User::where(...)->findAll();
// $resultの中身のイメージ
// [
//   User,
//   User,
//   User,
//   ...
// ];

$result[0]->getId(); // 1
$result[1]->getId(); // 2
```
的な感じで取れるように

- joinの場合(userテーブルにpostテーブルをjoinしたと仮定)
```php
$user = User::find();
$user->post->id; // postのid
$user->post[0]->id; // 1:2でjoinした場合
$user->id; // userのid
```
JOINした結果もこの章で組み立てられるようにしましょう。  
ここまでできればORMの完成です。  
これで基本的なSQLはPHP上で実行できるようになっているはずです。  
また、自作MVCフレームワークもこれで完成となります。  
ただし、フレームワークの完成はゴールではありません。  
フレームワークはアプリケーションを作成するための道具に過ぎないからです。  

```
【フィードバック】
クラスに配列のキーをプロパティとしてマッピングする。
レコードを複数取得して配列にした際に、各レコードをインスタンス化するという概念の理解が最初難しかった。
Joinが複数される場合のロジックが難しい（自分のは1回までしか無理）
```

## 掲示板を作ろう
ここまでの作業で、特定のURLにアクセスしたらControllerが選択されてModelから何かしらのデータを取ってきてViewに表示させる、といったことができるようになっています。あとはこのフレームワークを作って掲示板を作るだけです。  
今回の掲示板で必要な機能は以下となります。
```
ID/Passwordによるログイン
新規投稿（ログインしないと見られないように）
投稿の一覧（ログインしないと見られないように）
自分の投稿の編集・削除（ログインしないと見られないように）
```
掲示板の作成においては今回のフレームワーク作成では出てこなかったsessionやクッキーという仕組みを使ってユーザーを管理する必要がありますので、適宜調べて作ってみて下さい。

```
【フィードバック】
beforeメソッドとafterメソッドを基盤コントローラーに作るアイデアが出てこなかった。
ログインしないとみられないように認証を実装するのが難しかった。
```

## 最後に
実際のフレームワークはもっと今回の項目以上に細分化してあったり、複雑で多機能です。  
ですが根本でやってることは大体一緒なので、1度フレームワークを作っておくとこれから未知のフレームワークに遭遇した際に、「大体こうなってるはずだからこうすればいいだろう」という見当がつくようになるはずです。
