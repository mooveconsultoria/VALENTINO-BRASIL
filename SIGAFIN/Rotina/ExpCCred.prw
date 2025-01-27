#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "Report.Ch"
#INCLUDE "TOTVS.ch"

#DEFINE CRLF Chr(13)+Chr(10)


User Function ExpCCred()
Local cPerg     := "EspCCred"
Public __cFil   := Space(200)

If Perg(cPerg)
    FWMsgRun(,{|| Expxml()},"Aguarde","Aguarde... Realizando a geração do xml.")
    /*aSM0  := StrTokArr( MV_PAR01, ";" )
    for i = 1 To Len(aSM0)
        GeraxmlCCD(aSM0[i])
    Next*/
Else
    MsgAlert("Operação Cancelada pelo usuário")
Endif

return 
static function Expxml()
Local i
Local aSM0    := {}

aSM0  := StrTokArr( MV_PAR01, ";" )
    for i = 1 To Len(aSM0)
        GeraxmlCCD(aSM0[i])
    Next
return

static function Perg(cPerg)
local lRet := .F.
local aParBox 		:= {}


aadd(aParBox,{1,"Filiais p/ geração",Space(200)	,"","u_zRetFil()","","",50,.T.	})	//MV_PAR01
aadd(aParBox,{1,"Data Emissão de",CTOD("")							,"","","","",50,.F.	}) //MV_PAR02
aadd(aParBox,{1,"Data Emissão até",CTOD("")							,"","","","",50,.T.	}) //MV_PAR03
aAdd(aParBox,{6,"Salvar em",Space(200),"","","",50,.T.,"Todos os arquivos (*.*) |*.*",,GETF_LOCALHARD+GETF_RETDIRECTORY}) //MV_PAR04

lRet := ParamBox(aParBox,cPerg,,,,,,,,cPerg,.T.,.T.)

return lRet



User Function zRetFil( lPergunta)

Local aFil  := {}
//Local aSM0    := {}
Local aAreaSM0  := {}
Local nFil      := 0
Local __cFil    := ''
default lPergunta := .T.
aSM0    := {}
//lpergunrta indica se deverá ser exibda a tela para o usuário selecionar quais filiais deverão ser processadas
//Se lPergunta estiver .F., a função retornará todas as filiais da empresa sem exibir a tela para usuário.
If lPergunta

    aFil:= MatFilCalc( .T. )
    If len(aFil) == 0
        MsgAlert("Nenhuma filial foi selecionada, o processamento não será realizado")
    EndiF

Else
    
    aFil:= MatFilCalc( .F. )

EndIF

/*IF lPergunta
    //Adiciona filial logada para realizar o processamento
    AADD(aFil,{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC})
    __cFil    += SM0->M0_CODFIL + ";"
EndIF*/

IF  Len(aFil) > 0

    aAreaSM0 := SM0->(GetArea())
    DbSelectArea("SM0")
    //--------------------------------------------------------
    //Irá preencher aSM0 somente com as filiais selecionadas
    //pelo cliente
    //--------------------------------------------------------

    SM0->(DbGoTop())
    If SM0->(MsSeek(cEmpAnt))
        Do While !SM0->(Eof())
            nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
            If nFil > 0 .And. (aFil[nFil][1] .OR. !lPergunta) .AND. cEmpAnt == SM0->M0_CODIGO
                //Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
                __cFil    += alltrim(SM0->M0_CODFIL) + ";"
            EndIf
            SM0->(dbSkip())
        Enddo
    EndIf

    SM0->(RestArea(aAreaSM0))
EndIF
//MV_PAR01 := __cFil
__cFil := SubStr(__cFil,1,Len(__cFil)-1)
&(readvar()):= __cFil
Return .T.// 

Static Function GeraxmlCCD(cFil)

    Local cFile
    Local oFile
    Local cLinha  := GeraTags(cFil)
    If cLinha <> ""
    
        cFile    := Alltrim(MV_PAR04) + "FIN_" + Alltrim(cFil) + "_" + strtran(cValToChar(MV_PAR02),"/","") + "_ate_" +;
                          strtran(cValToChar(MV_PAR03),"/","") + "_" + strtran(cValToChar(ddatabase),"/","")  + "_" + strtran(time(),":","") + ".xml"
        oFile    := FWFileWriter():new(cFile)


//--    ------------- Se o arquivo já existe, apaga -------------------
        If oFile:Exists()()
            oFile:Erase()
        EndIf
        //-------------- Cria o arquivo --------------
        If (oFile:Create())


        //-------------- Se criou com sucesso, escreve ------------------------------
            oFile:Write(cLinha)
        //-------------- Fecha o arquivo -----------
            oFile:Close()
        Endif
    EndIf
Return
//Gera tags
Static Function GeraTags(cFilMov)

    Local aArea   := GetArea()
    Local cQuery	:= GetNextAlias()
    Local cSelect	:= ""
    Local cFrom     := ""
    Local cWhere    := ""
    Local cGroup    := ""
    Local cLinha    := ""
    Local cInvc_Sid := ""
    Local cDoc      := ""
    Local cSerie    := ""
        
        
    cSelect := " DISTINCT " 
    cSelect += " SF2.F2_FILIAL + SF2.F2_SERIE + SF2.F2_DOC INVC_SID, "
    cSelect += " SBS_NO = '1', "
    cSelect += " SF2.F2_FILIAL STORE_NO, "
    cSelect += " SL1.L1_NUM INVC_NO, "
    cSelect += " CASE WHEN SF2.F2_ESPECIE = 'NFCE' THEN SF2.F2_DOC ELSE '' END CF_NO, "
    cSelect += " CASE WHEN SF2.F2_ESPECIE = 'SPED' THEN SF2.F2_DOC ELSE '' END NF_E_NO, "
    cSelect += " SF2.F2_SERIE, "
    cSelect += " INVC_TYPE = '0', "
    cSelect += " SF2.F2_EMISSAO CREATED_DATE, "
    cSelect += " DISC_PRC = '0,00', "
    cSelect += " DISC_AMT = '0,00', "
    cSelect += " SD2.D2_ITEM ITEM_POS, "
    cSelect += " ( SELECT MAX(P.D2_ITEM) FROM " + RetSqlName("SD2")  + " P  WHERE SD2.D2_FILIAL  = '"  + xFilial("SD2",cFilMov)  + "' AND P.D2_DOC    = SD2.D2_DOC " +;
                  " AND P.D2_SERIE = SD2.D2_SERIE   AND P.D2_CLIENTE = SD2.D2_CLIENTE AND P.D2_LOJA    = SD2.D2_LOJA    AND P.D_E_L_E_T_ = ' ')  ITEM_MAIOR, " 
    cSelect += " SD2.D2_COD ALU, "
    cSelect += " SD2.D2_QUANT QTY, "
    cSelect += " SD2.D2_TOTAL - SD2.D2_DESCON ORIG_PRICE, "
    cSelect += " SD2.D2_TOTAL PRICE, "
    cSelect += " SD2.D2_VALIPI IPI_AMOUNT, "
    cSelect += " SD2.D2_VALICM ICMS_AMOUNT, "
    cSelect += " SD2.D2_VALIMP6 PIS_AMOUNT, "
    cSelect += " SD2.D2_VALIMP5 COFINS_AMOUNT  "
        
    cFrom += RetSqlName("SF2")    + " SF2 "
    cFrom += " INNER JOIN "+ RetSqlName("SD2")    + " SD2 ON (SD2.D2_FILIAL  = '"  + xFilial("SD2",cFilMov)  + "' AND SD2.D2_DOC    = SF2.F2_DOC     AND SD2.D2_SERIE = SF2.F2_SERIE   AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA    = SF2.F2_LOJA    AND SD2.D_E_L_E_T_ = ' ') "
    cFrom += " INNER JOIN "+ RetSqlName("SF4")    + " SF4 ON (SF4.F4_FILIAL  = '"  + xFilial("SF4",cFilMov)  + "' AND SF4.F4_CODIGO = SD2.D2_TES    AND  F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = ' ') "
    cFrom += " INNER JOIN "+ RetSqlName("SE1")    + " SE1 ON (SE1.E1_MSFIL   = '"  + xFilial("SF2",cFilMov)  + "' AND SE1.E1_NUM = SF2.F2_DOC AND SE1.E1_PREFIXO = SF2.F2_SERIE AND SE1.E1_TIPO IN ('CC','CD') AND SE1.D_E_L_E_T_ = ' ' ) "
    cFrom += " INNER JOIN "+ RetSqlName("SL1")    + " SL1 ON (SL1.L1_FILIAL  = '"  + xFilial("SL1",cFilMov)  + "' AND SL1.L1_DOC = SF2.F2_DOC AND SL1.L1_SERIE = SF2.F2_SERIE AND SL1.D_E_L_E_T_ = ' ') "    
            
    cWhere  := " SF2.F2_FILIAL   = '" + xFilial("SF2",cFilMov) + "' "
    cWhere  += " AND SF2.F2_EMISSAO   >= '" + DToS(MV_PAR02) + "' "
    cWhere  += " AND SF2.F2_EMISSAO   <= '" + DToS(MV_PAR03) + "' "
    cWhere  += " AND SF2.D_E_L_E_T_ = ' ' " 

    cOrder  := " INVC_SID "

    
    
    cSelect     := "%" + cSelect    + "%"
    
    cFrom       := "%" + cFrom      + "%"
        
    
    cWhere      := "%" + cWhere     + "%"

    cOrder      := "%" + cOrder     + "%"     


    BeginSql Alias cQuery

        
        SELECT %Exp:cSelect%
    	FROM   %Exp:cFrom% 
        
    	WHERE  %Exp:cWhere%

        ORDER BY %Exp:cOrder%

    EndSQL

    (cQuery)->(DBGotop())
    If (cQuery)->(!EOF())
        cLinha += '<?xml version="1.0" encoding="UTF-8"?>'
        cLinha += '<DOCUMENT>' + CRLF
        cLinha += '<INVOICES>' + CRLF
    EndIf
    While (cQuery)->(!EOF())
        If cInvc_Sid <> (cQuery)->INVC_SID
            
            cLinha += '<INVOICE invc_sid="' + Alltrim((cQuery)->INVC_SID) +'" sbs_no="'+ Alltrim((cQuery)->SBS_NO) + '" store_no="' + Alltrim((cQuery)->STORE_NO) +;
                      '" invc_no="' + Alltrim((cQuery)->INVC_NO) + '" CF_no="' + Alltrim((cQuery)->CF_NO) + '" NF-e_no="' + Alltrim((cQuery)->NF_E_NO) +;
                      '" invc_type="' + Alltrim((cQuery)->INVC_TYPE) + '" created_date="' + DToC(SToD((cQuery)->CREATED_DATE)) + '" disc_prc="' + Alltrim((cQuery)->DISC_PRC) +;
                      '" disc_amt="' + Alltrim((cQuery)->DISC_AMT) + '">' + CRLF + '<INVC_ITEMS>'  + CRLF
        EndIf

        cLinha += '<INVC_ITEM item_pos="' + Alltrim((cQuery)->ITEM_POS) +;
                  '" alu="' + Alltrim((cQuery)->ALU) +;
                  '" qty="' + Alltrim(str((cQuery)->QTY,7)) + ;
                  '" orig_price="' + strtran(Alltrim(str((cQuery)->ORIG_PRICE,16,2)),".",",") +;
                  '" price="' + strtran(Alltrim(str((cQuery)->PRICE,16,2)),".",",") +;
                  '" IPI_Amount="' + strtran(Alltrim(str((cQuery)->IPI_AMOUNT,14,2)),".",",") + ;
                  '" ICMS_Amount="' + strtran(Alltrim(str((cQuery)->ICMS_AMOUNT,14,2)),".",",") +;
                  '" PIS_Amount="' + strtran(Alltrim(str((cQuery)->PIS_AMOUNT,14,2)),".",",") +;
                  '" COFINS_Amount="' + strtran(Alltrim(str((cQuery)->COFINS_AMOUNT,14,2)),".",",") +;
                  '" />' + CRLF
        If (cQuery)->ITEM_MAIOR == (cQuery)->ITEM_POS
            cLinha += '</INVC_ITEMS>' + CRLF
            cDoc := IIf(Alltrim((cQuery)->NF_E_NO) <> "",Alltrim((cQuery)->NF_E_NO),Alltrim((cQuery)->CF_NO))
            cSerie := Alltrim((cQuery)->F2_SERIE)
            GeraCart(cDoc,cSerie,cFilMov,@cLinha)
            cLinha += '</INVOICE>' + CRLF
        EndIf

        cInvc_Sid := (cQuery)->INVC_SID
        (cQuery)->(dbskip())
    Enddo 
    If cLinha <> "" 
        cLinha += '</INVOICES>' + CRLF
        cLinha += '</DOCUMENT>' + CRLF
    EndIf
        
    (cQuery)->(dbCloseArea())
    RestArea(aArea)
Return cLinha

//GeraCart
Static Function GeraCart(cDoc,cSerie,cFilMov,cLinha)

    Local aArea   := GetArea()
    Local cQuery	:= GetNextAlias()
    Local cSelect	:= ""
    Local cFrom     := ""
    Local cWhere    := ""
    Local cGroup    := ""
    Local cCardName := ""
    Local nCount    := 1
    
        
    cSelect := " (SELECT SUM(P.E1_VALOR) FROM SE12H0 P WHERE P.E1_NUM = SE1.E1_NUM AND P.E1_PREFIXO = SE1.E1_PREFIXO AND P.E1_CLIENTE = SE1.E1_CLIENTE AND P.E1_LOJA = SE1.E1_LOJA AND P.E1_TIPO IN ( 'CC', 'CD' )  AND P.D_E_L_E_T_ = '' ) AMOUNT,  "
    cSelect += " (SELECT COUNT(P.E1_VALOR) FROM SE12H0 P WHERE P.E1_NUM = SE1.E1_NUM AND P.E1_PREFIXO = SE1.E1_PREFIXO AND P.E1_CLIENTE = SE1.E1_CLIENTE AND P.E1_LOJA = SE1.E1_LOJA AND P.E1_TIPO IN ( 'CC', 'CD' )  AND P.D_E_L_E_T_ = '' ) QTYTIMES, "
    cSelect += " SE1.E1_NOMCLI CARDNAME, "
    cSelect += " EXPMOTHYEAR = '', "
    cSelect += " SE1.E1_CARTAO CARDNUMBER, "
    cSelect += " SE1.E1_CARTAUT AUTH, "
    cSelect += " SE1.E1_NSUTEF NSU, "
    cSelect += " SAE.AE_TAXA TAXPERC, "
    cSelect += " SAE.AE_DIAS QTYDAYS, "
    cSelect += " SE1.E1_VALOR PARC_, "
    cSelect += " SE1.E1_VENCTO DATA_, "
    cSelect += " SE1.E1_CLIENTE "
        
    cFrom += RetSqlName("SF2")    + " SF2 "
    
    cFrom += " INNER JOIN "+ RetSqlName("SE1")    + " SE1 ON (SE1.E1_MSFIL   = '"  + xFilial("SF2",cFilMov)  + "' AND SE1.E1_NUM = SF2.F2_DOC AND SE1.E1_PREFIXO = SF2.F2_SERIE AND SE1.E1_TIPO IN ('CC','CD') AND SE1.D_E_L_E_T_ = ' ' ) "
    cFrom += " INNER JOIN "+ RetSqlName("SL1")    + " SL1 ON (SL1.L1_FILIAL  = '"  + xFilial("SL1",cFilMov)  + "' AND SL1.L1_DOC = SF2.F2_DOC AND SL1.L1_SERIE = SF2.F2_SERIE AND SL1.D_E_L_E_T_ = ' ') "    
    cFrom += " INNER JOIN "+ RetSqlName("SAE")    + " SAE ON (SAE.AE_FILIAL  = '"  + xFilial("SAE",cFilMov)  + "' AND SAE.AE_COD = SE1.E1_CLIENTE AND SAE.D_E_L_E_T_ = ' ')"
            
    cWhere  := " SF2.F2_FILIAL   = '" + xFilial("SF2",cFilMov) + "' "
    cWhere  += " AND SF2.F2_EMISSAO   >= '" + DToS(MV_PAR02) + "' "
    cWhere  += " AND SF2.F2_EMISSAO   <= '" + DToS(MV_PAR03) + "' "
    cWhere  += " AND SF2.F2_DOC        = '" + cDoc           + "' "
    cWhere  += " AND SF2.F2_SERIE      = '" + cSerie         + "' "
    cWhere  += " AND SF2.D_E_L_E_T_ = ' ' " 

    cOrder   := " SE1.E1_CLIENTE, SE1.E1_VENCTO "

    
    
    cSelect     := "%" + cSelect    + "%"
    
    cFrom       := "%" + cFrom      + "%"
        
    
    cWhere      := "%" + cWhere     + "%"
    
    cOrder      := "%" + cOrder     + "%"       


    BeginSql Alias cQuery

        
        SELECT %Exp:cSelect%
    	FROM   %Exp:cFrom% 
        
    	WHERE  %Exp:cWhere%

        ORDER BY %Exp:cOrder%

    EndSQL

    (cQuery)->(DBGotop())
    If (cQuery)->(!EOF())
        cLinha += '<INVC_TENDERS_ADD>' + CRLF
    EndIf
    While (cQuery)->(!EOF())
        If cCardName <> (cQuery)->E1_CLIENTE
            nCount  := 1
            cLinha += '<INVC_TENDER_ADD Name="CARTAO' +;
                      '" Amount="'      + strtran(Alltrim(str((cQuery)->AMOUNT,  14,2)),".",",")+;
                      '" QtyTimes="'    + strtran(Alltrim(str((cQuery)->QTYTIMES,7)),".",",") +;
                      '" CardName="'    + Alltrim((cQuery)->CARDNAME) +;
                      '" CardNumber="'     + Alltrim((cQuery)->CARDNUMBER) +;
                      '" ExpMothYear="' + Alltrim((cQuery)->EXPMOTHYEAR) +;
                      '" Nsu="'         + Alltrim((cQuery)->NSU) +;
                      '" Auth="'        + Alltrim((cQuery)->AUTH) +;
                      '" TaxPerc="'     + strtran(Alltrim(str((cQuery)->TAXPERC,  4,2)),".",",")+;
                      '" QtyDays="'     + strtran(Alltrim(str((cQuery)->QTYDAYS,  2)),".",",")+;
                      '">' + CRLF

        EndIf

        cLinha += '<DetailCad Parc_' + cValToChar(nCount) + 'de' +strtran(Alltrim(str((cQuery)->QTYTIMES,7)),".",",") + '="' + strtran(Alltrim(str((cQuery)->PARC_,  14,2)),".",",") +;
                  '" Tax_' + cValToChar(nCount) + 'de' +strtran(Alltrim(str((cQuery)->QTYTIMES,7)),".",",") + '="' + strtran(Alltrim(str(((cQuery)->PARC_*(cQuery)->TAXPERC),  14,2)),".",",") +;
                  '" Data_'+ cValToChar(nCount) + 'de' +strtran(Alltrim(str((cQuery)->QTYTIMES,7)),".",",") + '="' + DToC(SToD((cQuery)->DATA_)) +;
                  '"/>' + CRLF
                    
        If nCount == (cQuery)->QTYTIMES
            cLinha += '</INVC_TENDER_ADD>' + CRLF
        EndIf

        cCardName := (cQuery)->E1_CLIENTE
        nCount++
        (cQuery)->(dbskip())
    Enddo   
    (cQuery)->(DBGotop())
    If (cQuery)->(!EOF())
        cLinha += '</INVC_TENDERS_ADD>'  + CRLF
    EndIf
    
    (cQuery)->(dbCloseArea())   
    RestArea(aArea)
Return
