module Main where

import Graphics.X11.Turtle
import Text.XML.YJSVG hiding (topleft)
import Control.Concurrent
import Control.Monad
import Control.Applicative
import Data.IORef
import Data.Char
import System.Environment
import System.IO.Unsafe

st, sp :: Bool
st = unsafePerformIO $ read <$> readFile "show_turtle.txt"
sp = unsafePerformIO $ read <$> readFile "show_page.txt"

rt, width, height :: Double
rt = unsafePerformIO $ read <$> readFile "ratio.txt"
width = 512 * rt
height = 375 * rt

fontName :: String
fontName = "KochiGothic"

biggerF, bigF, semiBigF, normalF :: Double
biggerF = 36 * rt
bigF = 24 * rt
semiBigF = 15 * rt
normalF = 12 * rt

main :: IO ()
main = do
	(bfn, pages', bn) <- (flip fmap getArgs) $ \args -> case args of
		"-" : m : n : _ -> (Nothing,
			take (read n - read m) $ drop (read m) pages, read m)
		f : m : n : _ -> (Just f,
			take (read n - read m) $ drop (read m) pages, read m)
		"-" : n : _ -> (Nothing, drop (read n) pages, read n)
		f : n : _ -> (Just f, drop (read n) pages, read n)
		"-" : _ -> (Nothing, pages, 0)
		f : _ -> (Just f, pages, 0)
		_ -> (Nothing, pages, 0)
	pagesRef <- newIORef $ zip (map (mkSVGFileName bfn) [0 .. ]) pages'
	pageNRef <- newIORef [bn ..]
	f <- openField
--	threadDelay 1000000
	topleft f
	n <- newTurtle f
	hideturtle n
	penup n
	goto n (width * 46 / 50) (height * 48 / 50)
	t <- newTurtle f
	shape t "turtle"
	hideturtle t
	penup t
	onkeypress f $ \c -> do
		case c of
			'q' -> return False
			' ' -> do
				ps <- readIORef pagesRef
				case ps of
					(fn, p) : ps -> do
						when sp $ do
							clear n
							write n fontName (12 * rt)
								. show
								=<< popRef pageNRef
						when st $ showturtle t
						p t
						sleep t 500
						hideturtle t
						svg <- getSVG t
						case fn of
							Just f -> writeFile f $
								showSVG width
									height svg
							_ -> return ()
						modifyIORef pagesRef tail
						return True
					_ -> return True
			_ -> return True
	waitField f

popRef :: IORef [a] -> IO a
popRef ref = do
	ret <- head <$> readIORef ref
	modifyIORef ref tail
	return ret

mkSVGFileName :: Maybe String -> Int -> Maybe String
mkSVGFileName (Just bfn) n = Just $ bfn ++ addZero (show n) ++ ".svg"
	where
	addZero s = replicate (2 - length s) '0' ++ s
mkSVGFileName _ _ = Nothing

titlePage :: Turtle -> IO ()
titlePage t = do
	writeTitle t title "第1回 Haskellの特徴"
	writeRB t author

title, author :: String
title = "Haskell入門"
author = "重城 良国"

pages :: [Turtle -> IO ()]
pages = [
	titlePage, what1, what2, what3, what4, what5, what6, what7, what7_5,
	what7_6, what7_7, what7_8, what7_9, what8_1, what8_2, what8_3,
	what9, what10, what11, what12, what13,
	pure1 0,
	function1, function2,
	functionCheck1, functionCheck2, functionCheck3,
	functionCheck5, functionCheck6, functionCheck7, functionCheck8,
	functionCheck10,
	pure1 1,
	firstclass1, firstclass2, firstclass3, firstclass4, -- firstclass5,
	firstclassExam1, firstclassExam2, firstclassExam3,
	firstclassExam4, firstclassExam5,
	syntax1, syntax2, syntax3,
	higherOrder1, higherOrder2, higherOrder3, higherOrder4,
	higherOrder5,
	higherOrderCheck1, higherOrderCheck2, higherOrderCheck3,
	higherOrderCheck4, higherOrderCheck5, higherOrderCheck6,
	pure1 2,
	transparency1, transparency2, transparency3, transparency4,
	transparency5, transparency6, transparency7, transparency8,
	pure1 3,
	whatIsType1, whatIsType2, whatIsType3, whatIsType3_1,
	whatIsType4, whatIsType4_5,
	whatIsType5, whatIsType6, whatIsType7,
	whatIsType8,
	staticTyping1,
	pure1 4
 ]

what1 :: Turtle -> IO ()
what1 t = do
	clear t
	writeTopTitle t "Haskellとは何か?"

what2 :: Turtle -> IO ()
what2 t = do
	setheading t $ - 90
	forward t $ 10 * rt
	setx t $ width / 3
	image t "HaskellBCurry.jpg" (279 * rt / 2) (343 * rt / 2)
	forward t (343 * rt / 2)
	text t "Haskell Brooks Curry (1900.9.12 - 1982 9.1)"
	text t "アメリカの記号論理学者"
	text t "名前の由来はこの人"

what3 :: Turtle -> IO ()
what3 t = do
	silentundo t 23
	setx t $ width * 2 / 3
	image t "HaskellBCurry.jpg" (279 * rt / 2) (343 * rt / 2)
	text t "遅延評価型の関数型言語の乱立"
	setx t $ width / 3
	dvLArrow t 12
	text t "1990年 標準としてのHaskell 1.0"
	setx t $ width / 3
	dvLArrow t 12
	text t "Haskell 98、Haskell'、Haskell 2010"
	itext t 4 "と進化した"
	setx t $ width / 3
	dvLArrow t 12
	text t "ghc(代表的な処理系)内での拡張機能として進化は続く"
	y <- ycor t
	setx t $ width * 5 / 32
	setheading t $ - 90
	forward t $ normalF * 3 / 2
	left t 90
	arrow t $ 12 * rt
	sety t y
	itext t 1 "十分に吟味されたものが次の標準に取り込まれる"

what4 :: Turtle -> IO ()
what4 t = do
	silentundo t 115
	text t "研究者の努力の結晶"

what5 :: Turtle -> IO ()
what5 t = do
	setx t $ width / 3
	dvLArrow t 12
	text t "Haskellを学ぶということは"
	itext t 1 "彼らの成果を刈り取ること"
	text t ""

what6 :: Turtle -> IO ()
what6 t = do
	text t "難しい理論の理解が必要?"

what7 :: Turtle -> IO ()
what7 t = do
	setx t $ width / 3
	dvLArrow t 12
	text t "難しい理論は「利用者が簡単に使う」ためにある"

what7_5 :: Turtle -> IO ()
what7_5 t = do
	itext t 1 "レゴブロックを使うのにひとつひとつのブロックの"
	itext t 1 "作りかたを知る必要はない"

what7_6 :: Turtle -> IO ()
what7_6 t = do
	silentundo t $ if st then 103 else 97
	semititle t "何ができるの?"

what7_7 :: Turtle -> IO ()
what7_7 t = do
	text t "* C言語にできることは何でも"

what7_8 :: Turtle -> IO ()
what7_8 t = do
	itext t 0.5 "FFIという機能でCの関数が使える"
	setheading t $ -90
	forward t $ normalF * 13 / 8
	left t 90
	setx t $ width / 8

what7_9 :: Turtle -> IO ()
what7_9 t = do
	arrow t $ width / 20
	left t 90
	forward t $ normalF * 13 / 8
	itext t 1 "実用的な言語"
	text t ""

what8_1 :: Turtle -> IO ()
what8_1 t = do
	semititle t "他の言語を使い続けるとしても"

what8_2 :: Turtle -> IO ()
what8_2 t = do
	text t "* Haskellを学ぶことによって"
	itext t 1 "得られる様々な抽象化の手法は使える"

what8_3 :: Turtle -> IO ()
what8_3 t = do
	text t "* プログラミングに本質的な様々な概念を"
	itext t 1 "新たな光のもとに別の視点から見ることができる"

what9 :: Turtle -> IO ()
what9 t = do
--	silentundo t $ if st then 100 else 91
--	silentundo t $ if st then 5 else 4
	clear t
	writeTopTitle t "Haskellの特徴"
	setx t $ width * 2 / 3
	text t "純粋関数型言語であり"
	itext t 1 "* 第一級関数"
	itext t 1 "* 参照透過性"
	itext t 1 "* 静的型付け"
	itext t 1 "* 遅延評価"
	text t "という特徴を持つ"

what10 :: Turtle -> IO ()
what10 t = do
	backward t $ 50 * rt
	dvLArrow t 12
	text t "概念の本質的な部分をそのまま表現できる"
	text t ""

what11, what12, what13 :: Turtle -> IO ()
what11 t = text t "例: 小さい方から10個の素数が欲しい"
what12 t = text t "=> すべての素数を求める"
what13 t = text t "-> 小さい方から10個取り出す"

pure1 :: Int -> Turtle -> IO ()
pure1 n t = do
	flushoff t
	hideturtle t
	clear t
	writeTopTitle t "Haskellの特徴"
	(if n == 0 then withRed t else id) $ semititle t "純粋関数型言語"
	(if n == 1 then withRed t else id) $ semititle t "* 第一級関数"
	(if n == 2 then withRed t else id) $ semititle t "* 参照透過性"
	(if n == 3 then withRed t else id) $ semititle t "* 静的型付け"
	(if n == 4 then withRed t else id) $ semititle t "* 遅延評価"
	flushon t

withRed :: Turtle -> IO a -> IO a
withRed t act = do
	pencolor t "red"
	r <- act
	pencolor t "black"
	return r

function1 :: Turtle -> IO ()
function1 t = do
	clear t
	writeTopTitle t "関数とは?"

function2 :: Turtle -> IO ()
function2 t = do
	text t ""
	text t "0個以上の入力値をひとつの出力値へ変えるルール"
	goto t (width * 1 / 10) (height * 5 / 10)
	mkFunGraph t

functionCheck1, functionCheck2, functionCheck3, functionCheck5,
	functionCheck6, functionCheck7, functionCheck8, functionCheck10
	:: Turtle -> IO ()
functionCheck1 t = do
	clear t
	writeTopTitle t "関数とは?(練習問題)"
	semititle t "以下の「関数」の入力と出力を述べよ"

functionCheck2 t = text t "足し算"
functionCheck3 t = text t "翻訳"
functionCheck5 t = text t "与えられた文字列を表示する機能"
functionCheck6 t = text t "" >> text t "答え"
functionCheck7 t = text t "足し算: 数 -> 数 -> 数"
functionCheck8 t = text t "翻訳: ある言語の文 -> 別の言語の文"
functionCheck10 t = text t "与えられた文字列を表示する機能: 文字列 -> 動作"

mkFunGraph :: Turtle -> IO ()
mkFunGraph t = do
	write t fontName semiBigF "入力1"
	setheading t $ - 90
	forward t (height * 1 / 5)
	write t fontName semiBigF "入力2"
	backward t (height * 1 / 5 + semiBigF / 2)
	left t 90
	forward t (width * 5 / 40)
	x <- xcor t
	arrow t (width * 1 / 10)
	setheading t $ - 90
	forward t (height * 1 / 5)
	left t 90
	setx t x
	arrow t (width * 1 / 10)
	setheading t 0
	goto t (width * 135 / 364) (height * 2 / 5)
	pensize t $ 2 * rt
	pendown t
	replicateM_ 2 $ do
		forward t (width * 1 / 4)
		right t 90
		forward t (height * 7 / 20)
		right t 90
	penup t
	pensize t $ 1 * rt
	goto t (width * 13 / 20) (height * 23 / 40)
	pendown t
	arrow t (width * 1 / 10)
	setheading t (- 90)
	forward t $ semiBigF / 2
	left t 90
	forward t (12 * rt)
	write t fontName semiBigF "出力"

arrow :: Turtle -> Double -> IO ()
arrow t l = do
	pendown t
	pensize t $ 3 * rt
	forward t l
	left t 90
	penup t
	backward t (6 * rt)
	beginfill t
	forward t (12 * rt)
	right t 120
	forward t (12 * rt)
	endfill t
	pensize t $ 1 * rt

firstclass1 :: Turtle -> IO ()
firstclass1 t = do
	clear t
	writeTopTitle t "第一級関数とは?"

firstclass2 :: Turtle -> IO ()
firstclass2 t = do
	text t "関数が第一級オブジェクトであるということ"

firstclass3 :: Turtle -> IO ()
firstclass3 t = do
	writeNextTitle t "第一級オブジェクトとは?"

firstclass4 :: Turtle -> IO ()
firstclass4 t = do
	text t "* リテラルとして表現できる"
	text t "* 変数に格納できる"
	text t "* データ構造に格納できる"
	text t "* 関数の引数になれる"
	text t "* 関数の返り値になれる"

firstclassExam1, firstclassExam2, firstclassExam3, firstclassExam4,
	firstclassExam5 :: Turtle -> IO ()

firstclassExam1 t = do
	silentundo t 51
	text t "* リテラルとして表現できる"
	itext t 1 "\\x -> x * x"

firstclassExam2 t = do
	text t "* 変数に格納できる"
	itext t 1 "square = \\x -> x * x"

firstclassExam3 t = do
	text t "* データ構造に格納できる"
	itext t 1 "[\\x -> x * x]"

firstclassExam4 t = do
	text t "* 関数の引数になれる"
	itext t 1 "twice fun x = fun (fun x)"
	itext t 1 "twice sqrt 9 => 1.7320508075688772"

firstclassExam5 t = do
	text t "* 関数の返り値になれる"
	itext t 1 "addN n = \\x -> x + n"
	itext t 1 "(addN 3) 8 => 11"

syntax1, syntax2, syntax3 :: Turtle -> IO ()
syntax1 t = do
	clear t
	writeTopTitle t "ここまでに出てきた構文"
	text t "* 関数リテラル: \\parm -> expression"
	text t "* リストリテラル: [expression1, expression2, ... ]"
	text t "* 定義: var = expression"
	text t "* 関数定義: fun parm1 parm2 = expression"
	text t "* 関数適用: fun arg1 arg2"
	text t ""
syntax2 t = do
	text t "(注1) 変数の定義と"
	itext t 1 "0個の引数を取る関数の定義とは同じこと"
syntax3 t = do
	text t "(注2) 関数適用の結果を`=> value'のような"
	itext t 1 "形で示すが、これはHaskellの構文ではない。"

higherOrder1 :: Turtle -> IO ()
higherOrder1 t = do
	clear t
	writeTopTitle t "高階関数"
	text t "高階関数とは引数または返り値が関数であるような関数"

higherOrder2 :: Turtle -> IO ()
higherOrder2 t = do
	text t "つまり"
	text t ""
	text t "関数が第一級オブジェクトである"
	setx t $ width / 3
	dvArrow t
	text t "高階関数が書ける"
	text t ""
	text t "ということ"

higherOrder3 :: Turtle -> IO ()
higherOrder3 t = do
	silentundo t 55
	text t "何がうれしいの?"
	text t ""

higherOrder4 :: Turtle -> IO ()
higherOrder4 t = do
	text t "* より高レベルな抽象化"
	itext t 1 "枠組だけを定義することが可能"
	itext t 1 "例: リストの要素のすべてに何かする"

higherOrder5 :: Turtle -> IO ()
higherOrder5 t = do
	setx t $ width / 3
	dvArrow t
	text t "他の言語の「構文」が普通の関数となる"

higherOrderCheck1 :: Turtle -> IO ()
higherOrderCheck1 t = do
	clear t
	writeTopTitle t "高階関数(練習問題)"
	semititle t "以下の関数を定義せよ"

higherOrderCheck2 :: Turtle -> IO ()
higherOrderCheck2 t = text t "与えられた関数を3回適用する関数"

higherOrderCheck3 :: Turtle -> IO ()
higherOrderCheck3 t = do
	text t "10を底とした対数を求める関数を返す関数"
	itext t 1 "(ちなみに、logBase 10 1000 => 3)"
	text t ""

higherOrderCheck4 :: Turtle -> IO ()
higherOrderCheck4 t = text t "答え:"

higherOrderCheck5 :: Turtle -> IO ()
higherOrderCheck5 t = do
	text t "与えられた関数を3回適用する関数"
	itext t 1 "threeTimes fun x = fun (fun (fun x))"

higherOrderCheck6 :: Turtle -> IO ()
higherOrderCheck6 t = do
	text t "10を底とした対数を求める関数を返す関数"
	itext t 1 "log10 = \\x -> logBase 10 x"

transparency1, transparency2, transparency3, transparency4, transparency5,
	transparency6, transparency7, transparency8
	:: Turtle -> IO ()
transparency1 t = do
	clear t
	writeTopTitle t "参照透過性とは?"

transparency2 t = do
	text t "同じ関数を同じ入力で呼び出せば"
	itext t 1 "出力は常に同じであるという性質"
	text t ""

transparency3 t = do
	text t "参照透過ではない例"

transparency4 t = do
	itext t 1 "C 言語"
	itext t 1 "counter() => 0"
	itext t 1 "counter() => 1"
	itext t 1 "counter() => 2"
	itext t 1 ""

transparency5 t = do
	itext t 1 "Ruby"
	itext t 1 "counter.count => 0"
	itext t 1 "counter.count => 1"
	itext t 1 "counter.count => 2"

transparency6 t = do
	silentundo t $ if st then 90 else 90
	text t "Haskellでは同じ入力からは常に同じ出力"
	setx t $ width / 3
	dvArrow t
	text t "関数適用はその出力である値に置き換えることができる"
	itext t 1 $ "f x => 3"
	itext t 1 $ "g (f x) == g 3"
	text t "この場合、f x と 3 は全く同じ物と考えてよい"
	text t ""

transparency7 t = do
	semititle t "Haskellでの「関数」とは"
	text t "動作や手続き?"

transparency8 t = do
	let v = normalF * 9 / 8
	setheading t 90
	forward t v
	setx t $ width / 8
	y <- ycor t
	pensize t 2
	pendown t
	goto t (width / 3) (y + v)
	penup t
	forward t v
	pendown t
	goto t (width / 8) (y + v)
	penup t
	pensize t 1
	text t "「置き換え規則」である"

whatIsType1, whatIsType2, whatIsType3, whatIsType3_1,
	whatIsType4, whatIsType4_5,
	whatIsType5, whatIsType6, whatIsType7 :: Turtle -> IO ()
whatIsType1 t = clear t >> writeTopTitle t "型とは?"
whatIsType2 t = semititle t "値の集合"
whatIsType3 t = do
	text t "Int: 1, 2, 3, ..."
	text t "Char: 'a', 'b', 'c' ..."
whatIsType3_1 t = do
	text t "* 値valが型Typeに属するとき「valはType型の値」という"
	text t ""
whatIsType4 t = semititle t "再び... 関数とは?"
whatIsType4_5 t = do
	text t "ある集合に属する値を他の集合に属する値に写像するもの"
	itext t 3 "(写像: 入力から出力を得ること)"
whatIsType5 t = text t "例:"
whatIsType6 t = text t "絶対値 => 数の集合から数の集合への写像"
whatIsType7 t = text t "文字コードを返す関数 => 文字の集合から数の集合への写像"

whatIsType8 :: Turtle -> IO ()
whatIsType8 t = do
	silentundo t $ if st then 94 else 76
	semititle t "関数の型"

staticTyping1 :: Turtle -> IO ()
staticTyping1 t = do
	clear t
	writeTopTitle t "静的型付け"

dvArrow :: Turtle -> IO ()
dvArrow t = do
	setheading t $ -90
	forward t $ 12 * rt
	pendown t
	forward t $ 24 * rt
	penup t
	backward t $ 24 * rt
	left t 90
	forward t $ 6 * rt
	right t 90
	pendown t
	forward t $ 24 * rt
	setheading t 0
	forward t $ 3 * rt
	beginfill t
	backward t $ 12 * rt
	setheading t $ -60
	forward t $ 12 * rt
	endfill t
	penup t

dvLArrow :: Turtle -> Double -> IO ()
dvLArrow t l = do
	setheading t $ -90
	forward t $ 12 * rt
	pendown t
	forward t $ l * rt
	penup t
	backward t $ l * rt
	left t 90
	forward t $ 6 * rt
	right t 90
	pendown t
	forward t $ l * rt
	setheading t 0
	forward t $ 3 * rt
	beginfill t
	backward t $ 12 * rt
	setheading t $ -60
	forward t $ 12 * rt
	endfill t
	penup t

myLength :: String -> Double
myLength "" = 0
myLength (c : cs)
	| isAscii c = 0.7 + myLength cs
	| otherwise = 1.4 + myLength cs

semititle :: Turtle -> String -> IO ()
semititle t txt = do
	setheading t $ - 90
	forward t $ semiBigF * 2
	setheading t 0
	setx t $ width / 12
	write t fontName semiBigF txt
	forward t $ semiBigF * myLength txt

text :: Turtle -> String -> IO ()
text t txt = do
	setheading t $ - 90
	forward t $ normalF * 2
	setheading t 0
	setx t $ width / 8
	write t fontName normalF txt
	forward t $ normalF * myLength txt

itext :: Turtle -> Double -> String -> IO ()
itext t i txt = do
	setheading t $ - 90
	forward t $ normalF * 2
	setheading t 0
	setx t $ width / 8 + i * normalF * 4
	write t fontName normalF txt
	forward t $ normalF * myLength txt

writeTopTitle :: Turtle -> String -> IO ()
writeTopTitle t ttl = do
	let sz = bigF
	goto t ((width - sz * myLength ttl) / 2) ((height - sz) / 6)
	write t fontName sz ttl
	forward t $ sz * myLength ttl

writeNextTitle :: Turtle -> String -> IO ()
writeNextTitle t ttl = do
	let sz = bigF
	setheading t $ -90
	forward t $ sz * 2
	left t 90
	setx t $ (width - sz * myLength ttl) / 2
	write t fontName sz ttl
	forward t $ sz * myLength ttl

writeTitle :: Turtle -> String -> String -> IO ()
writeTitle t ttl subTtl = do
	let	sz = biggerF
		szn = normalF
	goto t ((width - sz * myLength ttl) / 2) ((height - sz) / 2)
	write t fontName sz ttl
	forward t $ sz * myLength ttl
	goto t ((width - szn * myLength subTtl) / 2) ((height - sz) / 2 + szn * 2)
	write t fontName szn subTtl
	forward t $ szn * myLength subTtl

writeRB :: Turtle -> String -> IO ()
writeRB t str = do
	let sz = normalF
	goto t (width * 3 / 4) (height * 7 / 8)
	write t fontName sz str
	forward t $ width * 3 / 16
