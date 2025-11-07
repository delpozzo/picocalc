' Video Poker v1.0
' by Mike Del Pozzo
' 06 November 2025
' License: GPLv3

'Card Suits
Const CLUBS=0
Const DIAMONDS=1
Const HEARTS=2
Const SPADES=3

'Card States
Const INDECK=0
Const DRAWN=1
Const HELD=2
Const DISCARDED=3

'Face Cards
Const JACK=11
Const QUEEN=12
Const KING=13
Const ACE=14

'Rounds
Const GAMEOVER=0
Const DEAL=1
Const DRAW=2

'Winning Hands
Const NONE=0
Const JACKSORBETTER=1
Const TWOPAIR=2
Const THREEOFAKIND=3
Const STRAIGHT=4
Const REGFLUSH=5
Const FULLHOUSE=6
Const FOUROFAKIND=7
Const STRAIGHTFLUSH=8
Const ROYALFLUSH=9

'Card Deck
Dim integer cardValue(52)
Dim integer cardSuit(52)
Dim integer cardState(52)
Dim integer hand(5)

'Variables
exitGame=0
betAmount=1
winAmount=0
balance=25
selectedCard=0
pickedCard=0
winType=NONE
straightFlag=0
flushFlag=0
currentRound=DRAW
card0=0
card1=0
card2=0
card3=0
card4=0

'Load Game
Sub LoadGame
  On Error Skip
  Open "poker.sav" For input As #1
  If MM.Errno <> 0 Then
    SaveGame
    Exit Sub
  EndIf
  Line Input #1,tmp$
  balance=Val(tmp$)
  If balance < 1 Then
    balance=25
  EndIf
  Close #1
End Sub

'Save Game
Sub SaveGame
  Open "poker.sav" For output As #1
  Print #1, balance
  Close #1
End Sub

'Game Initialization
Sub InitGame
  Randomize Timer
  Color RGB(white),RGB(0,0,128)
  CLS
  Box 15,15,290,150,2,RGB(white),RGB(0,0,64)
End Sub

'Initialize Card Deck
Sub InitCards
  suit=0
  For i=0 To 51
    cardSuit(i)=suit
    cardValue(i) = 2+(i Mod 13)
    cardState(i)=INDECK
    If (2+(i Mod 13))=14 Then suit=suit+1
  Next i
End Sub

'Clear Hand
Sub ClearHand
  For i=0 To 51
    cardState(i)=INDECK
  Next i

  Font 1
  Color RGB(0,0,128),RGB(0,0,128)
  Print @(25,295)"          "
  Font 2
  Print @(16,175)"                         "
End Sub

'Deal Cards
Sub DealCards
  For i=0 To 4
    retry1: pickedCard=Rnd*51
    If cardState(pickedCard)=INDECK Then
      hand(i)=pickedCard
      cardState(pickedCard)=DRAWN
    Else
      GoTo retry1
    EndIf
  Next i
End Sub

'Cheat Deal (for testing)
Sub CheatDeal
  hand(0)=0
  cardState(0)=DRAWN
  hand(1)=13
  cardState(13)=DRAWN
  hand(2)=1
  cardState(1)=DRAWN
  hand(3)=14
  cardState(14)=DRAWN
  hand(4)=26
  cardState(26)=DRAWN
End Sub

'Draw Cards
Sub DrawCards
  For i=0 To 4
    tempCard=hand(i)
    If cardState(tempCard)=DRAWN Then
      retry2: pickedCard=Rnd*51
      If cardState(pickedCard)=INDECK Then
        cardState(tempCard)=DISCARDED
        hand(i)=pickedCard
        cardState(pickedCard)=DRAWN
      Else
        GoTo retry2
      EndIf
    EndIf
  Next i
End Sub

'Select Card
Sub SelectCard
  Box 15,200,50,80,2,RGB(black),-1
  Box 75,200,50,80,2,RGB(black),-1
  Box 135,200,50,80,2,RGB(black),-1
  Box 195,200,50,80,2,RGB(black),-1
  Box 255,200,50,80,2,RGB(black),-1

  If selectedCard=0 Then
    Box 15,200,50,80,2,RGB(red),-1
  ElseIf selectedCard=1 Then
    Box 75,200,50,80,2,RGB(red),-1
  ElseIf selectedCard=2 Then
    Box 135,200,50,80,2,RGB(red),-1
  ElseIf selectedCard=3 Then
    Box 195,200,50,80,2,RGB(red),-1
  ElseIf selectedCard=4 Then
    Box 255,200,50,80,2,RGB(red),-1
  EndIf
End Sub

'Hold Card
Sub HoldCard
  tmpCard=hand(selectedCard)
  holdX=16+(selectedCard*60)
  Font 2
  Color RGB(yellow),RGB(0,0,128)

  If cardState(tmpCard)=DRAWN Then
    cardState(tmpCard)=HELD
    Print @(holdX,175)"HELD"
    HoldSound
  ElseIf cardState(tmpCard)=HELD Then
    cardState(tmpCard)=DRAWN
    Print @(holdX,175)"    "
    UnHoldSound
  EndIf
End Sub

'Sound Effects
Sub CardFlipSound
  Play tone 270,270,45
  Pause 90
  Play tone 370,370,45
End Sub

Sub BetSound
  note=300+(betAmount<<5)
  Play tone note,note,45
End Sub

Sub HoldSound
  Play tone 250,250,45
  Pause 120
  Play tone 350,350,45
End Sub

Sub UnHoldSound
  Play tone 350,350,45
  Pause 120
  Play tone 250,250,45
End Sub

Sub WinSound
  Pause 200
  Play tone 480,480,150
  Pause 200
  Play tone 480,480,100
  Pause 110
  Play tone 645,645,360
End Sub

'Display Payouts
Sub DispPayouts
  Font 1
  'Box 15,15,290,150,2,RGB(white),RGB(0,0,64)
  Color RGB(grey),RGB(0,0,64)
  If winType=ROYALFLUSH Then Color RGB(yellow)
  Print @(90,30)"Royal Flush x250"
  Color RGB(grey)
  If winType=STRAIGHTFLUSH Then Color RGB(yellow)
  Print @(35,55)"S.Flush   x50"
  Color RGB(grey)
  If winType=FOUROFAKIND Then Color RGB(yellow)
  Print @(35,80)"4-Kind    x25"
  Color RGB(grey)
  If winType=FULLHOUSE Then Color RGB(yellow)
  Print @(35,105)"F.House   x9"
  Color RGB(grey)
  If winType=REGFLUSH Then Color RGB(yellow)
  Print @(35,130)"Flush     x6"
  Color RGB(grey)
  If winType=STRAIGHT Then Color RGB(yellow)
  Print @(185,55)"Straight  x4"
  Color RGB(grey)
  If winType=THREEOFAKIND Then Color RGB(yellow)
  Print @(185,80)"3-Kind    x3"
  Color RGB(grey)
  If winType=TWOPAIR Then Color RGB(yellow)
  Print @(185,105)"Two Pair  x2"
  Color RGB(grey)
  If winType=JACKSORBETTER Then Color RGB(yellow)
  Print @(185,130)"Jacks+    x1"
End Sub

'Display Balance
Sub DispBalance
  Font 1
  Color RGB(white),RGB(0,0,128)
  Print @(225,295)"Bal:$      "
  Print @(225,295)"Bal:$";Format$(balance)
End Sub

'Update Balance
Sub UpdateBalance
  If winAmount > 0 Then
    Font 1
    Color RGB(white),RGB(red)
    Print @(25,295)"Win:$";Format$(winAmount)
    balance=balance+winAmount
    winAmount=0
    DispBalance
    WinSound
  Else If balance < 1 Then
    currentRound=GAMEOVER
    ClearHand
    DispGameOver
  EndIf
End Sub

'Display Bet
Sub DispBet
  Font 1
  Color RGB(white),RGB(0,0,128)
  Print @(136,295)"Bet:$";Format$(betAmount)
End Sub

'Display Card Backs
Sub DispCardBacks
  Box 15,200,50,80,2,RGB(black),RGB(grey)
  Box 75,200,50,80,2,RGB(black),RGB(grey)
  Box 135,200,50,80,2,RGB(black),RGB(grey)
  Box 195,200,50,80,2,RGB(black),RGB(grey)
  Box 255,200,50,80,2,RGB(black),RGB(grey)
End Sub

'Display Cards
Sub DispCards
  Font 2

  'Card 1
  If cardState(hand(0))=DRAWN Then
    Box 15,200,50,80,2,RGB(black),RGB(grey)
    Pause 300
    CardFlipSound
    Box 15,200,50,80,2,RGB(black),RGB(white)
    If (cardSuit(hand(0))=HEARTS) Or (cardSuit(hand(0))=DIAMONDS) Then
      Color RGB(red),RGB(white)
    Else
      Color RGB(black),RGB(white)
    EndIf
    If cardValue(hand(0))=14 Then
      Print @(18,202)"A"
    ElseIf cardValue(hand(0))=13 Then
      Print @(18,202)"K"
    ElseIf cardValue(hand(0))=12 Then
      Print @(18,202)"Q"
    ElseIf cardValue(hand(0))=11 Then
      Print @(18,202)"J"
    Else
      Print @(18,202)Format$(cardValue(hand(0)))
    EndIf
    If cardSuit(hand(0))=DIAMONDS Then
      Text 40,240,Chr$(137),CM,4,2
    ElseIf cardSuit(hand(0))=CLUBS Then
      Text 40,240,Chr$(138),CM,4,2
    ElseIf cardSuit(hand(0))=SPADES Then
      Text 40,240,Chr$(139),CM,4,2
    ElseIf cardSuit(hand(0))=HEARTS Then
      Text 40,240,Chr$(140),CM,4,2
    EndIf
  EndIf

  'Card 2
  If cardState(hand(1))=DRAWN Then
    Box 75,200,50,80,2,RGB(black),RGB(grey)
    Pause 300
    CardFlipSound
    Box 75,200,50,80,2,RGB(black),RGB(white)
    If (cardSuit(hand(1))=HEARTS) Or (cardSuit(hand(1))=DIAMONDS) Then
      Color RGB(red),RGB(white)
    Else
      Color RGB(black),RGB(white)
    EndIf
    If cardValue(hand(1))=14 Then
      Print @(77,202)"A"
    ElseIf cardValue(hand(1))=13 Then
      Print @(77,202)"K"
    ElseIf cardValue(hand(1))=12 Then
      Print @(77,202)"Q"
    ElseIf cardValue(hand(1))=11 Then
      Print @(77,202)"J"
    Else
      Print @(77,202)Format$(cardValue(hand(1)))
    EndIf
    If cardSuit(hand(1))=DIAMONDS Then
      Text 100,240,Chr$(137),CM,4,2
    ElseIf cardSuit(hand(1))=CLUBS Then
      Text 100,240,Chr$(138),CM,4,2
    ElseIf cardSuit(hand(1))=SPADES Then
      Text 100,240,Chr$(139),CM,4,2
    ElseIf cardSuit(hand(1))=HEARTS Then
      Text 100,240,Chr$(140),CM,4,2
    EndIf
  EndIf

  'Card 3
  If cardState(hand(2))=DRAWN Then
    Box 135,200,50,80,2,RGB(black),RGB(grey)
    Pause 300
    CardFlipSound
    Box 135,200,50,80,2,RGB(black),RGB(white)
    If (cardSuit(hand(2))=HEARTS) Or (cardSuit(hand(2))=DIAMONDS) Then
      Color RGB(red),RGB(white)
    Else
      Color RGB(black),RGB(white)
    EndIf
    If cardValue(hand(2))=14 Then
      Print @(137,202)"A"
    ElseIf cardValue(hand(2))=13 Then
      Print @(137,202)"K"
    ElseIf cardValue(hand(2))=12 Then
      Print @(137,202)"Q"
    ElseIf cardValue(hand(2))=11 Then
      Print @(137,202)"J"
    Else
      Print @(137,202)Format$(cardValue(hand(2)))
    EndIf
    If cardSuit(hand(2))=DIAMONDS Then
      Text 160,240,Chr$(137),CM,4,2
    ElseIf cardSuit(hand(2))=CLUBS Then
      Text 160,240,Chr$(138),CM,4,2
    ElseIf cardSuit(hand(2))=SPADES Then
      Text 160,240,Chr$(139),CM,4,2
    ElseIf cardSuit(hand(2))=HEARTS Then
      Text 160,240,Chr$(140),CM,4,2
    EndIf
  EndIf

  'Card 4
  If cardState(hand(3))=DRAWN Then
    Box 195,200,50,80,2,RGB(black),RGB(grey)
    Pause 300
    CardFlipSound
    Box 195,200,50,80,2,RGB(black),RGB(white)
    If (cardSuit(hand(3))=HEARTS) Or (cardSuit(hand(3))=DIAMONDS) Then
      Color RGB(red),RGB(white)
    Else
      Color RGB(black),RGB(white)
    EndIf
    If cardValue(hand(3))=14 Then
      Print @(197,202)"A"
    ElseIf cardValue(hand(3))=13 Then
      Print @(197,202)"K"
    ElseIf cardValue(hand(3))=12 Then
      Print @(197,202)"Q"
    ElseIf cardValue(hand(3))=11 Then
      Print @(197,202)"J"
    Else
      Print @(197,202)Format$(cardValue(hand(3)))
    EndIf
    If cardSuit(hand(3))=DIAMONDS Then
      Text 220,240,Chr$(137),CM,4,2
    ElseIf cardSuit(hand(3))=CLUBS Then
      Text 220,240,Chr$(138),CM,4,2
    ElseIf cardSuit(hand(3))=SPADES Then
      Text 220,240,Chr$(139),CM,4,2
    ElseIf cardSuit(hand(3))=HEARTS Then
      Text 220,240,Chr$(140),CM,4,2
    EndIf
  EndIf

  'Card 5
  If cardState(hand(4))=DRAWN Then
    Box 255,200,50,80,2,RGB(black),RGB(grey)
    Pause 300
    CardFlipSound
    Box 255,200,50,80,2,RGB(black),RGB(white)
    If (cardSuit(hand(4))=HEARTS) Or (cardSuit(hand(4))=DIAMONDS) Then
      Color RGB(red),RGB(white)
    Else
      Color RGB(black),RGB(white)
    EndIf
    If cardValue(hand(4))=14 Then
      Print @(257,202)"A"
    ElseIf cardValue(hand(4))=13 Then
      Print @(257,202)"K"
    ElseIf cardValue(hand(4))=12 Then
      Print @(257,202)"Q"
    ElseIf cardValue(hand(4))=11 Then
      Print @(257,202)"J"
    Else
      Print @(257,202)Format$(cardValue(hand(4)))
    EndIf
    If cardSuit(hand(4))=DIAMONDS Then
      Text 280,240,Chr$(137),CM,4,2
    ElseIf cardSuit(hand(4))=CLUBS Then
      Text 280,240,Chr$(138),CM,4,2
    ElseIf cardSuit(hand(4))=SPADES Then
      Text 280,240,Chr$(139),CM,4,2
    ElseIf cardSuit(hand(4))=HEARTS Then
      Text 280,240,Chr$(140),CM,4,2
    EndIf
  EndIf
End Sub

'Sort Cards
Sub SortCards
  For i=0 To 3
    For j=(1+i) To 4
      tmp1=hand(i)
      tmp2=hand(j)
      If cardValue(tmp1) > cardValue(tmp2) Then
        tmpCard=hand(i)
        hand(i)=hand(j)
        hand(j)=tmpCard
      EndIf
    Next j
  Next i
End Sub

'Check Hand
Sub CheckHand
  straightFlag=0
  flushFlag=0
  winType=NONE

  SortCards
  card0=cardValue(hand(0))
  card1=cardValue(hand(1))
  card2=cardValue(hand(2))
  card3=cardValue(hand(3))
  card4=cardValue(hand(4))

  'set flush/straight flags first
  CheckFlush
  CheckStraight

  CheckRFlush
  If winType=ROYALFLUSH Then
    winAmount=250*betAmount
    Return
  EndIf

  CheckSFlush
  If winType=STRAIGHTFLUSH Then
    winAmount=50*betAmount
    Return
  EndIf

  CheckFourKind
  If winType=FOUROFAKIND Then
    winAmount=25*betAmount
    Return
  EndIf

  CheckFullHouse
  If winType=FULLHOUSE Then
    winAmount=9*betAmount
    Return
  EndIf

  If flushFlag=1 Then
    winType=REGFLUSH
    winAmount=6*betAmount
    Return
  EndIf

  If straightFlag=1 Then
    winType=STRAIGHT
    winAmount=4*betAmount
    Return
  EndIf

  CheckThreeKind
  If winType=THREEOFAKIND Then
    winAmount=3*betAmount
    Return
  EndIf

  CheckTwoPair
  If winType=TWOPAIR Then
    winAmount=2*betAmount
    Return
  EndIf

  CheckJacks
  If winType=JACKSORBETTER Then
    winAmount=betAmount
    Return
  EndIf
End Sub

'Win Conditions

Sub CheckJacks
  For i=0 To 4
    tmp1=hand(i)
    tmp2=hand(i+1)
    If (cardValue(tmp1)=cardValue(tmp2)) And cardValue(tmp2) > 10) Then
      winType=JACKSORBETTER
    EndIf
  Next i
End Sub

Sub CheckTwoPair
  If (card0=card1) And (card2=card3) Then
    winType=TWOPAIR
  ElseIf (card1=card2) And (card3=card4) Then
    winType=TWOPAIR
  ElseIf (card0=card1) And (card3=card4) Then
    winType=TWOPAIR
  EndIf
End Sub

Sub CheckThreeKind
  For i=0 To 2
    tmp1=hand(i)
    tmp2=hand(i+1)
    tmp3=hand(i+2)
    If (cardValue(tmp1)=cardValue(tmp2)) And (cardValue(tmp2)=cardValue(tmp3)) Then
      winType=THREEOFAKIND
    EndIf
  Next i
End Sub

Sub CheckStraight
  If (card4=card3+1) And (card3+1=card2+2) And (card2+2=card1+3) And (card1+3=card0+4) Then
    straightFlag=1
  ElseIf (card4=ACE) And (card0=2) And (card1=3) And (card2=4) And (card3=5) Then
    straightFlag=1
  EndIf
End Sub

Sub CheckFlush
  If (cardSuit(hand(0))=cardSuit(hand(1))) And (cardSuit(hand(1))=cardSuit(hand(2))) And (cardSuit(hand(2))=cardSuit(hand(3))) And (cardSuit(hand(3))=cardSuit(hand(4))) Then
    flushFlag=1
  EndIf
End Sub

Sub CheckFullHouse
  If (card0=card1) And (card1=card2) And (card3=card4) Then
    winType=FULLHOUSE
  ElseIf (card0=card1) And (card2=card3) And (card3=card4) Then
    winType=FULLHOUSE
  EndIf
End Sub

Sub CheckFourKind
  If (card0=card1) And (card1=card2) And (card2=card3) Then
    winType=FOUROFAKIND
  ElseIf (card1=card2) And (card2=card3) And (card3=card4) Then
    winType=FOUROFAKIND
  EndIf
End Sub

Sub CheckSFlush
  If (straightFlag=1) And (flushFlag=1) Then
    winType=STRAIGHTFLUSH
  EndIf
End Sub

Sub CheckRFlush
  If (flushFlag=1) And (card0=10) And (card1=JACK) And (card2=QUEEN) And (card3=KING) And (card4=ACE) Then
    winType=ROYALFLUSH
  EndIf
End Sub

'Entry Point
InitGame
InitCards
LoadGame
DispPayouts
DispCardBacks
DispBalance
DispBet

'Flush Input Buffer
Sub FlushInput
  Do
    a$=Inkey$
  Loop Until a$=""
End Sub

'Regular Input
Sub HandleInput
  a$=Inkey$
  If a$=Chr$(27) Then
    exitGame=1
  ElseIf a$=Chr$(131) And currentRound=DEAL Then
    selectedCard=selectedCard+1
    If selectedCard=5 Then selectedCard=0
    SelectCard
  ElseIf a$=Chr$(130) And currentRound=DEAL Then
    selectedCard=selectedCard-1
    If selectedCard=-1 Then selectedCard=4
    SelectCard
  ElseIf a$=Chr$(128) And currentRound=DRAW Then
    betAmount=betAmount+1
    If betAmount=6 Then betAmount=1
    DispBet
    BetSound
  ElseIf a$=Chr$(129) And currentRound=DRAW Then
    betAmount=betAmount-1
    If betAmount=0 Then betAmount=5
    DispBet
    BetSound
  ElseIf a$=" " And currentRound=DEAL Then
    HoldCard
  ElseIf a$=Chr$(13) And currentRound=DEAL Then
    currentRound=DRAW
    selectedCard=-1
    SelectCard
    DrawCards
    DispCards
    CheckHand
    UpdateBalance
    DispPayouts
    FlushInput
  ElseIf a$=Chr$(13) And currentRound=DRAW Then
    currentRound=DEAL
    winType=NONE
    ClearHand
    DispCardBacks
    If betAmount > balance Then
      betAmount=balance
      DispBet
    EndIf
    balance=balance-betAmount
    If balance < 0 Then
      balance=0
    EndIf
    DispBalance
    DispPayouts
    DealCards
    DispCards
    selectedCard=0
    SelectCard
    FlushInput
  EndIf
End Sub

'Game Over Input
Sub GameOverInput
  a$=Inkey$
  If a$=Chr$(27) Then
    exitGame=1
  ElseIf a$=Chr$(13) Then
    balance=25
    ClearHand
    DispCardBacks
    DispBalance
    currentRound=DRAW
  EndIf
End Sub

'Display Game Over
Sub DispGameOver
  Font 1
  Color RGB(white),RGB(red)
  Print @(65,175)"Game Over. Press (Enter)"
  Pause 200
  UnHoldSound
End Sub

'Main Loop
Do
  If currentRound=GAMEOVER Then
    GameOverInput
  Else
    HandleInput
  EndIf
Loop While exitGame=0

SaveGame
Font 1
Color RGB(green),RGB(black)
CLS
Print "Thank you for playing Video Poker!"
Print ""
End
