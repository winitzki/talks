import Graphics.Element (..)
import Text (..)
import Signal (..)
import Graphics.Input as Input

after_unless : (Bool, Bool) -> Bool -> Bool
after_unless (b,p) w = (w || b) && not p

boss_and_phone : Signal (Bool, Bool)
boss_and_phone = map2 (\x y->(x,y)) bossS phoneS

i_work : Signal Bool
i_work = foldp after_unless False boss_and_phone

init_state = { boss = False, phone = False, work = False }

main : Signal Element
main = map draw merge_state

merge_state = map3 (\x y z->{boss=x,phone=y,work=z}) bossS phoneS i_work

bossC = channel False
phoneC = channel False

bossS = subscribe bossC
phoneS = subscribe phoneC

make_checkbox b_channel b_data b_name = 
  flow right
    [ container 30 30 middle (Input.checkbox (send b_channel) b_data)
    , container 150 30 midLeft (plainText b_name)
    ]

draw { boss, phone, work } =
 let work_text = if work then "I am working" else "I am drinking tea" in
 flow down [
    make_checkbox bossC boss "Boss is nearby",
    make_checkbox phoneC phone "Phone is ringing",
    container 150 30 middle (plainText work_text)
 ]
