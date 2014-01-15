import Control.Applicative
import Control.Monad
import System.Random
import System.IO.Unsafe
import Data.IORef

import Lecture

subtitle :: String
subtitle = "第5回 演習(1日目)"

main :: IO ()
main = runLecture [
	[flip writeTitle subtitle], prelude,
	montecarlo, getPiAlgorithm,
	syntax, functions, exponentiation, smallerEqual, aboutFromIntegral,
	aboutFstSnd, aboutFstSnd2, aboutTake, aboutCycle, aboutZip,
	aboutRandom, aboutRandom2, aboutRandom3
 ]

prelude :: Page
prelude = [\t -> do
	writeTopTitle t "はじめに"
	text t "", \t -> do
	text t "* 今日は関数、型、タプル、リストについて学んだ", \t -> do
	text t "* タプルのところではパターンマッチについても学んだ", \t -> do
	text t "* 今の知識でできる演習問題を見ていくことにしよう", \t -> do
	text t "* モンテカルロ法で円周率を求める方法を見ていこう", \t -> do
	text t "* 必要となる関数を演習問題として出していこう"
 ]

montecarlo :: Page
montecarlo = [\t -> do
	writeTopTitle t "モンテカルロ法"
	text t "", \t -> do
	text t "* モンテカルロとは?", \t -> do
	itext t 1 "- カジノで有名なモナコ公国の1地区", \t -> do
	text t "* モンテカルロ法とは?", \t -> do
	itext t 1 "- 乱数を使うことで「決まった時間内」に", \t -> do
	itext t 1 "- 「正しい可能性の高い結果」が得られる", \t -> do
	text t "* 本当に正しいかどうかはわからない", \t -> do
	itext t 1 "- 一種の賭けである", \t -> do
	itext t 1 "- だから「モンテカルロ」法"
 ]

randomXY :: [(Double, Double)]
randomXY = unsafePerformIO $ replicateM 300 $ do
	x <- randomRIO (-1, 1)
	y <- randomRIO (-1, 1)
	return (x, y)

inPoints :: [(Int, Int)]
inPoints = flip zip [1 ..] $ tail $
	scanl (\ps (x, y) -> if inCircle x y then ps + 1 else ps) 0 randomXY

getPiAlgorithm :: Page
getPiAlgorithm = [\t -> do
	writeTopTitle t "アルゴリズム"
	text t "", \t -> do
	text t "* 円周率は半径1の円の面積に等しい", \t -> do
	text t "* 1辺が2の正方形のなかに半径1の円を書く", \t -> do
	text t "* ランダムに点を打つ", \t -> do
	text t "* 以下の値が円の面積に近づいていくと予測できる", \t -> do
	itext t 1"円の中にある点の数 / 全体の点の数 * 4", \t -> do
	drawRect2 t 150 220 120 120
	forwardRt t 60
	circleRt t 60
	t' <- mkHideTurtle (field t) 300 300
	writeRt t' "in    ="
	forwardRt t' 60
	t'' <- mkHideTurtle (field t) 300 320
	writeRt t'' "total ="
	forwardRt t'' 60
	t''' <- mkHideTurtle (field t) 300 340
	writeRt t''' "pi    ="
	forwardRt t''' 60
	writeRt t' $ show (0 :: Int)
	writeRt t'' $ show (0 :: Int)
	writeRt t''' $ show (0 :: Double)
--	replicateM_ 300 $ randomDot t 150 220 120 120
	forM_ (zip randomXY inPoints) $ \((x, y), (i, a)) -> do
		if inCircle x y then pencolor t "blue" else pencolor t "red"
		dotRt t (210 + 60 * x) (280 + 60 * y)
--		print i
--		print a
		waitTurtle t
		undo t'
		writeRt t' $ show i
		undo t''
		writeRt t'' $ show a
		undo t'''
		writeRt t''' $ take 5 $
			show (fromIntegral i / fromIntegral a * 4 :: Double)
	writeIORef killTurtles [t', t'', t'''], \t -> do
	readIORef killTurtles >>= mapM_ killTurtle
	pencolor t "black"
 ]

killTurtles :: IORef [Turtle]
killTurtles = unsafePerformIO $ newIORef []

mkHideTurtle :: Field -> Double -> Double -> IO Turtle
mkHideTurtle f x y = do
	t <- newTurtle f
	hideturtle t
	penup t
	rtGoto t x y
	return t

showDouble :: Int -> Double -> String
showDouble n d
	| d < 0 = take n $ show d
	| otherwise = ' ' : take (n - 1) (show d)

inCircle :: Double -> Double -> Bool
inCircle x y = x ^ (2 :: Int) + y ^ (2 :: Int) <= 1

syntax :: Page
syntax = [\t -> do
	writeTopTitle t "追加の構文"
	text t "", \t -> do
	text t "* 演習で使う追加の構文を見てみよう", \t -> do
	text t "* import [モジュール名] ([識別子1], [識別子2] ...)", \t -> do
	itext t 1 "- 指定したモジュールから指定した関数を取り込む", \t -> do
	text t "* 関数定義中のwhere", \t -> do
	itext t 1 "- where以下にその関数ローカルな環境を作る", \t -> do
	itext t 1 "fun x = y + z", \t -> do
	itext t 2 "where"
	preLine t
	itext t 3 "y = x * 2", \t -> do
	itext t 3 "z = 1 / x", \t -> do
	text t "* (値 :: 型)という形", \t -> do
	itext t 1 "- 値にオプショナルな型指定をつけることができる", \t -> do
	itext t 1 "- (3 :: Int) + 8など"
 ]

functions :: Page
functions = [\t -> do
	writeTopTitle t "追加の関数"
	text t "", \t -> do
	text t "* 以下のまだ説明していない関数を使う", \t -> do
	itext t 1 "(^), (<=), fromIntegral, fst, snd,"
	itext t 1 "take, cycle, zip, randomRs, mkStdGen", \t -> do
	text t "* ひとつずつ説明していこう"
 ]

ex1int1, ex1int2, ex1int3 :: Int
[ex1int1, ex1int2, ex1int3] = unsafePerformIO $ replicateM 3 $ randomRIO (2, 10)

ex1double1 :: Double
ex1double1 = unsafePerformIO $ ((/ 10) . fromIntegral) <$> randomRIO (11 :: Int, 99)

exponentiation :: Page
exponentiation = [\t -> do
	writeTopTitle t "べき乗"
	text t "", \t -> do
	text t "* (^)はべき乗を表す関数(演算子)", \t -> do
	text t "* x ^ nでxのn乗を表す", \t -> do
	text t "* やってみよう", \t -> do
	itext t 1 "% cd lectures", \t -> do
	itext t 1 "% mkdir lecture05", \t -> do
	itext t 1 "% cd lecture05", \t -> do
	itext t 1 "% ghci", \t -> do
	itext t 1 $ "Prelude> " ++ show ex1int1 ++ " ^ " ++ show ex1int2, \t -> do
	itext t 1 $ show $ ex1int1 ^ ex1int2, \t -> do
	itext t 1 $ "Prelude> " ++ show ex1double1 ++ " ^ " ++ show ex1int3, \t -> do
	itext t 1 $ show $ ex1double1 ^ ex1int3
 ]

se1int1, se1int2, se1int3, se1int4 :: Int
[se1int1, se1int2, se1int3, se1int4] =
	unsafePerformIO $ replicateM 4 $ randomRIO (2, 20)

smallerEqual :: Page
smallerEqual = [\t -> do
	writeTopTitle t "小なりイコール"
	text t "", \t -> do
	text t "* (<=)は「小なりイコール」を表す関数(演算子)", \t -> do
	text t "* x <= yは", \t -> do
	itext t 1 "- xがyより大きいときFalseを返し", \t -> do
	itext t 1 "- xがyと等しいかまたは小さいときにTrueを返す", \t -> do
	text t "* やってみよう", \t -> do
	itext t 1 $ "Prelude> " ++ show se1int1 ++ " <= " ++ show se1int2
	itext t 1 $ show $ se1int1 <= se1int2, \t -> do
	itext t 1 $ "Prelude> " ++ show se1int3 ++ " <= " ++ show se1int4
	itext t 1 $ show $ se1int3 <= se1int4
 ]

fi1int1, fi1int2 :: Int
[fi1int1, fi1int2] = unsafePerformIO $ replicateM 2 $ randomRIO (2, 20)

aboutFromIntegral :: Page
aboutFromIntegral = [\t -> do
	writeTopTitle t "fromIntegral"
	text t "", \t -> do
	text t "* fromIntegralは整数から他の型の数に変換する関数", \t -> do
	text t "* fromIntegral xで整数xを他の数値型に変換できる", \t -> do
	text t "* やってみよう", \t -> do
	itext t 1 $ "Prelude> fromIntegral (" ++ show fi1int1 ++ " :: Int) :: Double", \t -> do
	itext t 1 $ show $ (fromIntegral (fi1int1 :: Int) :: Double), \t -> do
	itext t 1 $ "Prelude> fromIntegral (" ++ show fi1int2 ++ " :: Int) :: Double", \t -> do
	itext t 1 $ show $ (fromIntegral (fi1int2 :: Int) :: Double)
 ]

aboutFstSnd :: Page
aboutFstSnd = [\t -> do
	writeTopTitle t "2要素タプルからの取り出し"
	text t "", \t -> do
	text t "* タプルからの要素の取り出しにはパターンマッチが使える", \t -> do
	itext t 1 "fun (x, y) = ...", \t -> do
	text t "* 2要素タプルには要素を取り出す関数が用意されている", \t -> do
	itext t 1 "- fst: タプルの一番目の要素を取り出す", \t -> do
	itext t 1 "- snd: タプルの二番目の要素を取り出す", \t -> do
	text t "* 以下のように定義できる", \t -> do
	itext t 1 "fst :: (a, b) -> a", \t -> do
	itext t 1 "fst (x, _) = x", \t -> do
	itext t 1 "snd :: (a, b) -> b", \t -> do
	itext t 1 "snd (_, y) = y"
 ]

fs2int1 :: Int
fs2int1 = unsafePerformIO $ randomRIO (1, 10)

fs2char1 :: Char
fs2char1 = unsafePerformIO $ randomRIO ('a', 'z')

fs2tuple1 :: (Int, Char)
fs2tuple1 = (fs2int1, fs2char1)

aboutFstSnd2 :: Page
aboutFstSnd2 = [\t -> do
	writeTopTitle t "2要素タプルからの取り出し"
	text t "", \t -> do
	text t "* やってみよう", \t -> do
	itext t 1 $ "Prelude> fst " ++ show fs2tuple1, \t -> do
	itext t 1 $ show $ fst fs2tuple1, \t -> do
	itext t 1 $ "Prelude> snd " ++ show fs2tuple1, \t -> do
	itext t 1 $ show $ snd fs2tuple1
 ]

tk1lst1, tk1lst2 :: [Int]
[tk1lst1, tk1lst2] = unsafePerformIO $ replicateM 2 $ do
	sg <- newStdGen
	return $ take 10 $ randomRs (0, 20) sg

tk1int1, tk1int2 :: Int
[tk1int1, tk1int2] = unsafePerformIO $ replicateM 2 $ randomRIO (2, 9)

aboutTake :: Page
aboutTake = [\t -> do
	writeTopTitle t "take"
	text t "", \t -> do
	text t "* takeはリストのはじめのn要素を取り出す関数", \t -> do
	itext t 1 "take :: Int -> [a] -> [a]", \t -> do
	text t "* やってみよう", \t -> do
	itext t 1 $ "Prelude> take " ++ show tk1int1 ++ " " ++ show tk1lst1, \t -> do
	itext t 1 $ show $ take tk1int1 tk1lst1, \t -> do
	itext t 1 $ "Prelude> take " ++ show tk1int2 ++ " " ++ show tk1lst2, \t -> do
	itext t 1 $ show $ take tk1int2 tk1lst2
 ]

ccl1str1 :: [Int]
[ccl1str1] = unsafePerformIO $ replicateM 1 $ do
	sg <- newStdGen
	return $ take 5 $ randomRs (0, 9) sg

ccl1str2 :: String
[ccl1str2] = unsafePerformIO $ replicateM 1 $ do
	sg <- newStdGen
	return $ take 5 $ randomRs ('a', 'z') sg

aboutCycle :: Page
aboutCycle = [\t -> do
	writeTopTitle t "cycle"
	text t "", \t -> do
	text t "* cycleはリストを無限にくりかえす関数", \t -> do
	itext t 1 "cycle :: [a] -> [a]", \t -> do
	text t "* ためすときはtakeと組み合わせると良い", \t -> do
	text t "* やってみよう", \t -> do
	itext t 1 $ "Prelude> take 20 $ cycle " ++ show ccl1str1, \t -> do
	itext t 1 $ show $ take 20 $ cycle ccl1str1, \t -> do
	itext t 1 $ "Prelude> take 30 $ cycle " ++ show ccl1str2, \t -> do
	itext t 1 $ show $ take 30 $ cycle ccl1str2
 ]

zp1lst1, zp1lst4 :: [Int]
[zp1lst1, zp1lst4] = unsafePerformIO $ forM [5, 5] $ \l -> do
	sg <- newStdGen
	return $ take l $ randomRs (0, 9) sg

zp1lst2, zp1lst3 :: String
[zp1lst2, zp1lst3] = unsafePerformIO $ forM [5, 7] $ \l -> do
	sg <- newStdGen
	return $ take l $ randomRs ('a', 'z') sg

aboutZip :: Page
aboutZip = [\t -> do
	writeTopTitle t "zip"
	text t "", \t -> do
	text t "* 2つのリストをタプルのリストに合成する関数", \t -> do
	itext t 1 "zip :: [a] -> [b] -> [(a, b)]", \t -> do
	text t "* やってみよう", \t -> do
	itext t 1 $ "Prelude> zip " ++ show zp1lst1 ++ " " ++ show zp1lst2, \t -> do
	itext t 1 $ show $ zip zp1lst1 zp1lst2, \t -> do
	itext t 1 $ "Prelude> zip " ++ show zp1lst3 ++ " " ++ show zp1lst4, \t -> do
	itext t 1 $ show $ zip zp1lst3 zp1lst4
 ]

aboutRandom :: Page
aboutRandom = [\t -> do
	writeTopTitle t "ランダム"
	text t "", \t -> do
	text t "* モンテカルロ法を使うためにはランダムな数列が必要", \t -> do
	text t "* System.RandomモジュールのrandomRsを使おう", \t -> do
	text t "* randomRsの型を以下のように考える", \t -> do
	itext t 1 "randomRs :: (Double, Double) -> StdGen -> [Double]", \t -> do
	text t "* 第一引数はタプルで、ランダム値の(下限, 上限)となる", \t -> do
	text t "* 第二引数のStdGenは見たことのない型だ", \t -> do
	text t "* ランダム関数には初期値が必要となり", \t -> do
	itext t 1 "これをランダムの種と呼んだりする", \t -> do
	text t "* 整数(Int)からStdGenへの変換関数が用意されている", \t -> do
	itext t 1 "mkStdGen :: Int -> StdGen"
 ]

rd2int1 :: Int
rd2int1 = unsafePerformIO $ randomRIO (0, 9999)

aboutRandom2 :: Page
aboutRandom2 = [\t -> do
	writeTopTitle t "ランダム"
	text t "", \t -> do
	text t "* やってみよう", \t -> do
	itext t 1 "Prelude> :m System.Random", \t -> do
	itext t 1 $ "Prelude System.Random> mkStdGen " ++ show rd2int1, \t -> do
	itext t 1 $ show $ mkStdGen rd2int1, \t -> do
	itext t 1 $ "Prelude System.Random> :t it", \t -> do
	itext t 2 "- :tで与えられた値の型を表示する", \t -> do
	itext t 2 "- 直前で評価した値は変数itに保存されている", \t -> do
	itext t 1 "it :: StdGen", \t -> do
	text t "* mkStdGenでStdGenの値が得られることがわかった"
 ]

rd3int1, rd3int2 :: Int
[rd3int1, rd3int2] = unsafePerformIO $ replicateM 2 $ randomRIO (0, 9999)

aboutRandom3 :: Page
aboutRandom3 = [\t -> do
	writeTopTitle t "ランダム"
	text t "", \t -> do
	itext t (-1) $ "Prelude System.Random> take 3 $ randomRs (1, 3) $"
		++ "mkStdGen " ++ show rd3int1, \t -> do
--	itext t 7 $ "mkStdGen " ++ show rd3int1, \t -> do
	itext t (-1) $ show $ take 3 $ randomRs (1 :: Double, 3) $ mkStdGen rd3int1, \t -> do
	itext t (-1) $ "Prelude System.Random> take 3 $ randomRs (1, 3) $"
		++ "mkStdGen " ++ show rd3int2, \t -> do
	itext t (-1) $ show $ take 3 $ randomRs (1 :: Double, 3) $ mkStdGen rd3int2, \t -> do
	itext t (-1) $ "Prelude System.Random> take 3 $ randomRs (1, 3) $"
		++ "mkStdGen " ++ show rd3int2, \t -> do
	itext t (-1) $ show $ take 3 $ randomRs (1 :: Double, 3) $ mkStdGen rd3int2, \t -> do
	text t "* 別の種には別の乱数列", \t -> do
	text t "* 同じ種には同じ乱数列"
 ]

-- (^), (<=), fromIntegral, fst, snd, take, cycle, zip, randomRs, mkStdGen


