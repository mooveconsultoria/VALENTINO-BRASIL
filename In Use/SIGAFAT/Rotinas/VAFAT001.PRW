#Include "Protheus.ch"
/******************************************************************************
* @Autor: Oscar Lira - TOTVS IP             @Data: 03/04/2023                 *
* @Descrição: Rotina para alimentar o campo de base do IPI e valor unitario   *
*             no pedido de vendas. A formula para a base de IPI usara o preco *
*             de vendas da SB0 quando for transferencia e o preco de custos   *
*             nos demais casos                                                *
* @Parametro: nOpcao ==> 1 - Base de IPI                                      *
*                        2 - Valor unitario                                   *
******************************************************************************/
User Function VAFAT001(nOpcao)
Local nRetorno  := 0
Local aAreaAnt  := GetArea()
Local aAreaSB0  := SB0->(GetArea())
Local aAreaSB1  := SB1->(GetArea())
Local aAreaSB2  := SB2->(GetArea())
Local cVar      := Upper(Alltrim(ReadVar()))
Local cCont     := &(ReadVar())
Local nPosProd  := aScan(aHeader,{ |x| Alltrim(x[2]) = "C6_PRODUTO"})
Local nPosQuant := aScan(aHeader,{ |x| Alltrim(x[2]) = "C6_QTDVEN" })
Local nPosBIPI  := aScan(aHeader,{ |x| Alltrim(x[2]) = "C6_BASIPI" })
Local nPosPrcV  := aScan(aHeader,{ |x| Alltrim(x[2]) = "C6_PRCVEN" })
Local cProd     := ""
Local nQuant    := 0

SB0->(dBSetOrder(1))  // B0_FILIAL+B0_COD
SB1->(dBSetOrder(1))  // B1_FILIAL+B1_COD
SB2->(dBSetOrder(1))  // B2_FILIAL+B2_COD+B2_LOCAL

cProd  := If(cVar = "M->C6_PRODUTO",cCont,aCols[n,nPosProd])
nQuant := If(cVar = "M->C6_QTDVEN",cCont,aCols[n,nPosQuant])

If !Empty(cProd) .and. SB1->(MsSeek(xFilial("SB1")+cProd))
    // Para transferencia utilizar o preco de venda como base de IPI e o custo como preco unitario
    If nOpcao = 1
        If M->C5_ZZTRANS == "S" .and. SB0->(MsSeek(xFilial("SB0")+cProd))
            nRetorno := SB0->B0_PRV1/(1+SB1->B1_IPI/100)
        Else  // se nao for transferencia mantem os valores padrao
            nRetorno := aCols[n,nPosBIPI]
        EndIf

        If nQuant > 0
            nRetorno := nRetorno*nQuant
        EndIf
    Else
        If M->C5_ZZTRANS == "S" .and. SB2->(MsSeek(xFilial("SB2")+cProd+"01"))
            nRetorno := SB2->B2_CM1
        Else // se nao for transferencia mantem os valores padrao
            nRetorno := aCols[n,nPosPrcV]
        EndIf
    EndIf
EndIf

RestArea(aAreaSB0)
RestArea(aAreaSB2)
RestArea(aAreaSB1)
RestArea(aAreaAnt)

Return nRetorno
