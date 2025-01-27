#INCLUDE "PROTHEUS.CH"
/*******************************************************************************
* Ponto de entrada que permite ajustar a alíquota e a base de calculo de IPI.  *
* Utilizado para ajustar as bases aliquotas para os produtos de determinados   *
* NCMs de acordo com a solicitacao de Wesley Lopes da area fiscal da Valentino *
* Parametros:                                                                  *
*    ParamIXB[1] Numerico Numero do Item                                       *
*    ParamIXB[2] Caracter Codigo do Produto                                    *
*    ParamIXB[3] Caracter Codigo da TES                                        *
*    ParamIXB[4] Caracter Tipo de Participante (C = Cliente/F = Fornecedor)    *
*    ParamIXB[5] Caracter Codigo do Participante                               *
*    ParamIXB[6] Caracter Codigo da Loja do Participante                       *
*    ParamIXB[7] Caracter Operacao da Nota Fiscal (E = Entrada/S = Saída)      *
* Retorno:                                                                     *
* aRet[1] Caracter Indica se calcula ou nao o IPI para o item. (S=Sim, N=Nao)  *
* aRet[2] Caracter Indica o percentual de aliquota para cálculo de IPI para o  *
*                  item. Caso seja passado zerado, o sistema desconsiderara o  *
*                  retorno dessa posicao, possibilitando que seja informado    *
*                  somente a base de calculo.                                  *
* aRet[3] Caracter Indica o valor de base de calculo que sera considerada para *
*                  calculo de IPI para o item. Caso seja passado zerado, o     *
*                  sistema desconsiderara o retorno dessa posicao, possibili-  *
*                  tando que seja informado somente a aliquota.                *
*******************************************************************************/
User Function MaCalcIPI()
/*Local nItem      := PARAMIXB[1] //Numero do Item
Local cProduto   := PARAMIXB[2] //Codigo do Produto
Local cTes       := PARAMIXB[3] //Codigo da TES
Local cCliFor    := PARAMIXB[4] //Tipo de Participante (C = Cliente/F = Fornecedor)
Local cCodCliFor := PARAMIXB[5] //Codigo do Participante
Local cLoja      := PARAMIXB[6] //Codigo da Loja do Participante
Local cOperNF    := PARAMIXB[7] //Operacao da Nota Fiscal (E = Entrada/S = Saida)*/
Local cProduto   := "" //Codigo do Produto
Local cTes       := "" //Codigo da TES
Local cOperNF    := "" //Operacao da Nota Fiscal (E = Entrada/S = Saida)
Local aRet     := {}
Local aAreaAnt := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSB0 := SB0->(GetArea())
Local aAreaSF4 := SF4->(GetArea())
Local cCalcIPI := "N" // S=Calcula IPI; N=Nao Calcula IPI.
Local nAliqIPI := 0  // Retorna o percentual de ali­quota do IPI.
Local nBaseIPI := 0  // Retorna a base de calculo do IPI.
Local nPosCod  := 0
Local nPosTES  := 0
Local nPosVUnit := 0
Local nPosQtde := 0
//Local nValUnit := 0

SB0->(dBSetOrder(1))  // B0_FILIAL+B0_COD
SB1->(dBSetOrder(1))  // B1_FILIAL+B1_COD
SF4->(dBSetOrder(1))  // F4_FILIAL+F4_CODIGO

If FwIsInCallStack("MATA103") .and. FwIsInCallStack("U_VACOM010")
    nPosCod   := aScan(aHeader,{|x| Alltrim(x[2]) = "D1_COD"})
    nPosTES   := aScan(aHeader,{|x| Alltrim(x[2]) = "D1_TES"})
    nPosVUnit := aScan(aHeader,{|x| Alltrim(x[2]) = "D1_VUNIT"})
    nPosQtde  := aScan(aHeader,{|x| Alltrim(x[2]) = "D1_QUANT"})

    cOperNF  := "E"
    cProduto := If(ReadVar() = "M->D1_COD", M->D1_COD, aCols[n,nPosCod])
    cTES     := If(ReadVar() = "M->D1_TES", M->D1_TES, aCols[n,nPosTES])
    //nValUnit := If(ReadVar() = "M->D1_VUNIT", M->D1_VUNIT, aCols[n,nPosVUnit])

    If !Empty(cProduto) .and. !Empty(cTES) .and. ;
        SB1->(MsSeek(xFilial("SB1")+cProduto) .and. B1_IPI > 0 .and. Left(B1_POSIPI,2) $ SuperGetMV("ZZ_NCMIPIT",.F.,"71,42")) .and. ;
        SF4->(MsSeek(xFilial("SF4")+cTES) .and. F4_IPI = "S") .and. SB0->(MsSeek(xFilial("SB0")+cProduto))

        cCalcIPI := "S"
        nAliqIPI := SB1->B1_IPI
        nBaseIPI := SB0->B0_PRV1/(1+(nAliqIPI/100))*aCols[n,nPosQtde]
    EndIf
EndIf

aAdd(aRet, cCalcIPI )
aAdd(aRet, nAliqIPI )
aAdd(aRet, nBaseIPI )

RestArea(aAreaSB0)
RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aAreaAnt)

Return aRet
