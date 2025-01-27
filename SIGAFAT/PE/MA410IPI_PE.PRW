#Include "PROTHEUS.CH"
//*------------------------------------------------------------------------------*
//* Rotina   : M410IPI / Ponto de Entrada
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
User Function M410IPI()

Local aAreaAnt := GetArea()
Local aAreaSB0 := SB0->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSB2 := SB2->(GetArea())
Local aAreaSF4 := SF4->(GetArea())

Local nPosProd := 0
Local nPosTES  := 0
//Local nPosPrcV := aScan(aHeader,{|x| Alltrim(x[2]) = "C6_PRCVEN"})
Local nItPed   := 0

// Nao executar se a chamada foi feita pela rotina de preparacao de documentos
If !FWIsInCallStack("MA410PVNFS")
	SB0->(dBSetOrder(1))  // B0_FILIAL+B0_COD
	SB1->(dBSetOrder(1))  // B1_FILIAL+B1_COD
	SB2->(dBSetOrder(1))  // B2_FILIAL+B2_COD+B2_LOCAL
	SF4->(dBSetOrder(1))  // F4_FILIAL+F4_CODIGO

	nItPed   := PARAMIXB[1]
	nPosProd := aScan(aHeader,{|x| Alltrim(x[2]) = "C6_PROD"})
	nPosTES  := aScan(aHeader,{|x| Alltrim(x[2]) = "C6_TES"})

	If M->C5_ZZTRANS = "S" .and. ;
		SB1->(MsSeek(xFilial("SB1")+aCols[nItPed,nPosProd]) .and. Left(B1_POSIPI,2) $ SuperGetMV("ZZ_NCMIPIT",.F.,"71,42")) .and. ;
		SB0->(MsSeek(xFilial("SB0")+aCols[nItPed,nPosProd])) .and. SF4->(MsSeek(xFilial("SF4")+aCols[nItPed,nPosTES]) .and. F4_IPI = "S")

		MaFisAlt("IT_ALIQIPI",SB1->B1_IPI,nItPed,.T.)
		MaFisAlt("IT_BASEIPI",(1+(SB1->B1_IPI/100))*QUANTIDADE,nItPed,.T.)

		ALIQIPI := SB1->B1_IPI
		BASEIPI := SB0->B0_PRV1/(1+(SB1->B1_IPI/100))*QUANTIDADE
	EndIf

	VALORIPI := BASEIPI * (ALIQIPI/100)

	RestArea(aAreaSF4)
	RestArea(aAreaSB0)
	RestArea(aAreaSB2)
	RestArea(aAreaSB1)
	RestArea(aAreaAnt)
EndIf

Return VALORIPI
