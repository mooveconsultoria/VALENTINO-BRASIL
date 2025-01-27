#Include "PROTHEUS.CH"

//*------------------------------------------------------------------------------*
//* Rotina   : M460IPI / Ponto de Entrada
//* Objetivo : Atualizar valores de IPI conforme Central XML
//* Programador : Richard Branco
//* Valriaveis disponiveis
//* VALORIPI, BASEIPI , QUANTIDADE, ALIQIPI, BASEIPIFRETE
//* Alterado para ajustar as bases aliquotas para os produtos de determinados    *
//* NCMs de acordo com a solicitacao de Wesley Lopes da area fiscal da Valentino *
//* Parametros:                                                                  *
//*    ParamIXB[1] Registro do SC9                                               *
//*    ParamIXB[2] Qual item do pedido de vendas está sendo processado           *
//* Retorno: Retorna o valor do IPI.                                             *
//* Observacao: FAZER O MESMO TRATAMENTO NO P.E. M410IPI                         *
//*------------------------------------------------------------------------------*
User Function M460IPI()

Local aAreaSB0 := SB0->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local aAreaSF4 := SF4->(GetArea())
Local xArea		:= GetArea()

/*
If SC6->C6_XBASIPI > 0
	ALIQIPI		:= SC6->C6_XPIPI
	BASEIPI     := SC6->C6_XBASIPI
	VALORIPI   	:= SC6->C6_XVALIPI
EndIf 
*/

SB0->(dBSetOrder(1))  // B0_FILIAL+B0_COD
SB1->(dBSetOrder(1))  // B1_FILIAL+B1_COD
SC5->(dBSetOrder(1))  // C5_FILIAL+C5_NUM
SC6->(dBSetOrder(1))  // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
SF4->(dBSetOrder(1))  // F4_FILIAL+F4_CODIGO

If SC5->(MsSeek(xFilial("SC5")+SC9->C9_PEDIDO) .and. C5_ZZTRANS = "S") .and. ;
    SB1->(MsSeek(xFilial("SB1")+SC9->C9_PRODUTO) .and. Left(B1_POSIPI,2) $ SuperGetMV("ZZ_NCMIPIT",.F.,"71,42")) .and. ;
    SB0->(MsSeek(xFilial("SB0")+SC9->C9_PRODUTO)) .and. ;
    SC6->(MsSeek(xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO))) .and. ;
    SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES) .and. F4_IPI = "S")

    ALIQIPI := SB1->B1_IPI
    BASEIPI := SB0->B0_PRV1/(1+(SB1->B1_IPI/100))*QUANTIDADE
EndIf

VALORIPI := BASEIPI * (ALIQIPI/100)

RestArea(aAreaSB0)
RestArea(aAreaSB1)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaSF4)

RestArea(xArea)

Return VALORIPI
