#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
    Ponto de entrada na transmissão da NF-e para tratamento adicionais
    20/04/2021
    TOTVS IP
*/

User Function PE01NFESEFAZ()

Local aArea 	:= Lj7GetArea({"SC5","SC6","SF1","SF2","SD1","SD2","SA1","SA2","SB1","SB5","SF4","SA3"})
Local aParam 	:= PARAMIXB //aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque
Local aProd		:= PARAMIXB[01]
Local cMensCli	:= PARAMIXB[02]
Local cMensFis	:= PARAMIXB[03]
Local aDest		:= PARAMIXB[04] 
Local aNota   	:= PARAMIXB[05]
Local aInfoItem	:= PARAMIXB[06]
Local aDupl		:= PARAMIXB[07]
Local aTransp	:= PARAMIXB[08]
Local aEntrega	:= PARAMIXB[09]
Local aRetirada	:= PARAMIXB[10]
Local aVeiculo	:= PARAMIXB[11]
Local aReboque	:= PARAMIXB[12]
Local aNfVincRur:= PARAMIXB[13]
Local aEspVol   := PARAMIXB[14]
Local aNfVinc   := PARAMIXB[15]
Local AdetPag   := PARAMIXB[16]
Local aObsCont	:= PARAMIXB[17]
Local aICMS     := PARAMIXB[18]
Local aRetorno	:= {}

//Altera as Informações carregadas para o XML
AltInfo(@aProd,@cMensCli,@cMensFis,@aDest,@aNota,aInfoItem,@aDupl,@aTransp,@aEntrega,@aRetirada,@aVeiculo,@aReboque,@aNfVincRur,@aEspVol,@aNfVinc,@AdetPag, @aObsCont, @aICMS)

//Retorna na Ordem Esperada no Fonte NFESEFAZ
aAdd(aRetorno , aProd)
aAdd(aRetorno , cMensCli)
aAdd(aRetorno , cMensFis)
aAdd(aRetorno , aDest)
aAdd(aRetorno , aNota)
aAdd(aRetorno , aInfoItem)
aAdd(aRetorno , aDupl)
aAdd(aRetorno , aTransp)
aAdd(aRetorno , aEntrega)	
aAdd(aRetorno , aRetirada)	
aAdd(aRetorno , aVeiculo)	
aAdd(aRetorno , aReboque)	
aadd(aRetorno , aNfVincRur)
aadd(aRetorno , aEspVol)
aadd(aRetorno , aNfVinc)
aadd(aRetorno , aDetPag)
aadd(aRetorno , aObsCont)
aadd(aRetorno , aICMS)

Lj7RestArea(aArea)  	

Return(aRetorno)

/*
Função que Altera as Informações do Arrays do XML da NF
*/
Static Function AltInfo(aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc,AdetPag,aObsCont,aICMS)
Local cSerie		:= aNota[01]
Local cDoc			:= aNota[02]
Local cTipo			:= aNota[04] //Tipo de Entrada/Saída - 2=Entrada / 1=Saída
Local cTipoNF		:= aNota[05] //Tipo da NF - F2_TIPO / F1_TIPO
Local nValPIS       := 0
Local nValCOF       := 0

If cTipo == "1"

    If SF2->F2_VALIMP6 + SF2->F2_VALIMP5 > 0

        cValPIS := Alltrim(TRANSFORM(SF2->F2_VALIMP6, GetSx3Cache("F2_VALIMP6","X3_PICTURE")))
        cValCOF := Alltrim(TRANSFORM(SF2->F2_VALIMP5, GetSx3Cache("F2_VALIMP5","X3_PICTURE")))

        cMsgAux := "Valor do PIS    : R$ " + cValPIS + CRLF
        cMsgAux += "Valor do COFINS : R$ " + cValCOF + CRLF
        cMsgAux += cMensCli

        cMensCli := cMsgAux

    Endif

Else

    If SF1->F1_VALIMP6 + SF1->F1_VALIMP5 > 0

        cValPIS := Alltrim(TRANSFORM(SF1->F1_VALIMP6, GetSx3Cache("F1_VALIMP6","X3_PICTURE")))
        cValCOF := Alltrim(TRANSFORM(SF1->F1_VALIMP5, GetSx3Cache("F1_VALIMP5","X3_PICTURE")))

        cMsgAux := "Valor do PIS    : R$ " + cValPIS + CRLF
        cMsgAux += "Valor do COFINS : R$ " + cValCOF + CRLF
        cMsgAux += cMensCli

        cMensCli := cMsgAux

    Endif

Endif

Return nil
