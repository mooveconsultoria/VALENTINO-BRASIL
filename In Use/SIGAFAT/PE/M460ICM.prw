#Include "PROTHEUS.CH"

//*------------------------------------------------------------------------------*
//* Rotina   : M460ICM / Ponto de Entrada
//* Objetivo : Grava os valores de ICMS do xml no pedido
//* Programador : Richard Branco
//* Valriaveis disponiveis
//* _ALIQICM   ,_QUANTIDADE, _BASEICM , _VALICM, _FRETE, _VALICMFRETE, _DESCONTO, _VALRATICM  ,_ACRESFIN
//*------------------------------------------------------------------------------*


User Function M460ICM()

Local xArea		:= GetArea()

If SC6->C6_XBASICM > 0
	_ALIQICM	:= SC6->C6_XPICM         
	_BASEICM    := SC6->C6_XBASICM
	_VALICM   	:=  SC6->C6_XVALICM
EndIf

RestArea(xArea)

Return .T.
