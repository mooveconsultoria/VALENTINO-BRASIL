#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'

// Relatório via Schedule
User Function VALRPTSCH()

Prepare environment empresa '2H' filial '00'
ConOut("Inicio - Relatorio de saldos em estoque VALRPT01")
    u_ValRpt01(.T.)
ConOut("Termino - Relatorio de saldos em estoque VALRPT01")

reset environment

Return

/*
    Função: VALRPT01
    Descrição: Relatório de Saldos em Estoque
    Autor: Roberto Santiago (Mistral)
*/
User Function VALRPT01(lSchedule)

    Local aPergs      := {}
    Local cQuery      := ''
    Local cTMPAlias   := ''
    Local oExcel      := FwMsExcelXlsx():New()
    Local cWorkSheet  := 'Saldos em Estoque'
    Local cTituloWS   := 'Relatório Saldos em Estoque - Valentino'
    Local cFilialDe   := ''
    Local cFilialAte  := 'ZZZ'
    Local cArmazemDe  := ''
    Local cArmazemAte := 'ZZZ'
    Local cProdutoDe  := ''
    Local cProdutoAte := 'ZZZ'
    Local cDirFile    := ''
    Local lQtdMzero   := .T.

    Default lSchedule := .F.

    If !lSchedule
        aAdd(aPergs, {1, "Filial De"       , Space(Len(cFilAnt))       , "", ".T.", "SM0", ".T.", 80, .F.})
        aAdd(aPergs, {1, "Filial Ate"      , Space(Len(cFilAnt))       , "", ".T.", "SM0", ".T.", 80, .F.})
        aAdd(aPergs, {1, "Armazem De"      , Space(TamSX3('B1_COD')[1]), "", ".T.", "NNR", ".T.", 80, .F.})
        aAdd(aPergs, {1, "Armazem Ate"     , Space(TamSX3('B1_COD')[1]), "", ".T.", "NNR", ".T.", 80, .F.})
        aAdd(aPergs, {1, "Produto De"      , Space(TamSX3('B1_COD')[1]), "", ".T.", "SB1", ".T.", 80, .F.})
        aAdd(aPergs, {1, "Produto Ate"     , Space(TamSX3('B1_COD')[1]), "", ".T.", "SB1", ".T.", 80, .F.})
        aAdd(aPergs, {2, "Qtd. Dif. de 0", 1                         , {"1=Sim", "2=Não"},90, ".T.", .F.})
        
        If ParamBox(aPergs, "Informe os parâmetros")
            cFilialDe   := MV_PAR01
            cFilialAte  := MV_PAR02
            cArmazemDe  := MV_PAR03
            cArmazemAte := MV_PAR04
            cProdutoDe  := MV_PAR05
            cProdutoAte := MV_PAR06
            lQtdMzero   := IIF(MV_PAR07 == 1,.T.,.F.)
        Else
            Return
        EndIf
    EndIf

    cQuery := QueryRegs(AllTrim(cFilialDe), AllTrim(cFilialAte), AllTrim(cArmazemDe), AllTrim(cArmazemAte), AllTrim(cProdutoDe), AllTrim(cProdutoAte),lQtdMzero) // Filial De, Filial Até, Armazem De, Armazem Ate, Produto De, Produto Ate

    TcQuery cQuery new Alias (cTMPAlias := GetNextAlias())

    DbSelectArea(cTMPAlias)
    (cTMPAlias)->(DbGoTop())

    oExcel:AddworkSheet(cWorkSheet)
    oExcel:AddTable(cWorkSheet,cTituloWS)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Filial"              , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Código do Produto"   , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Coleção"             , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Referência"          , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Linha"               , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Descrição do Produto", 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Cor"                 , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Tamanho"             , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Código de Barras"    , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Saldo Atual"         , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Valor em Estoque"    , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Preço de Venda"      , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Total de Venda"      , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Armazém"             , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Descrição do Armazém", 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Saldo em Terceiro"   , 1, 1)

    While (cTMPAlias)->(!Eof())
            //If (cTMPAlias)->B2_QATU > 0 .Or. (cTMPAlias)->B2_QNPT > 0 // considerar apenas registros com saldos em estoque ou em terceiros
                oExcel:AddRow(cWorkSheet,cTituloWS,;
                    {;
                        (cTMPAlias)->B2_FILIAL,;
                        (cTMPAlias)->B1_COD,;
                        (cTMPAlias)->B1_ZZCOLEC,;
                        (cTMPAlias)->B1_ZZREFER,;
                        (cTMPAlias)->B1_ZZLINE,;
                        (cTMPAlias)->B1_DESC,;
                        (cTMPAlias)->B1_ZZCOR,;
                        (cTMPAlias)->B1_ZZTAMAN,;
                        (cTMPAlias)->B1_CODBAR,;
                        (cTMPAlias)->B2_QATU,;
                        (cTMPAlias)->B2_VATU1,;
                        (cTMPAlias)->B0_PRV1,;
                        (cTMPAlias)->B0_PRV1*(cTMPAlias)->B2_QATU,;
                        (cTMPAlias)->B1_LOCPAD,;
                        (cTMPAlias)->B2_LOCALIZ,;
                        (cTMPAlias)->B2_QNPT;
                    };
                )
            //EndIf
        (cTMPAlias)->(DbSkip())
    EndDo

    (cTMPAlias)->(DbCloseArea())

    If !lSchedule
        cDirFile := TFileDialog("All Xlsx files (*.xlsx)","Salvar Arquivo",,"c:",.T.,GETF_RETDIRECTORY)
    Else
        //cDirFile := '/spool/valrpt01_'+DToS(Date())+'_'+Time()+'.xlsx'
        //cDirFile := GetTempPath()+'valrpt01.xml'
        cDirFile := 'valrpt01.xml'
    EndIf

    If File(cDirFile)
        fErase(cDirFile)
    EndIf

    oExcel:Activate()
    If oExcel:GetXMLFile(cDirFile)
        If lSchedule
            oExcel:DeActivate()

            If File("VALRPT01.XLSX")
                fErase("VALRPT01.XLSX")
            EndIf

            frename(cDirFile,"VALRPT01.XLSX")

            EnviaEmail("\SYSTEM\VALRPT01.XLSX", cFilialDe, cFilialAte, cArmazemDe, cArmazemAte, cProdutoDe, cProdutoAte)
        Else
            ShellExecute("OPEN", cDirFile, "", "", 1)
            oExcel:DeActivate()
        EndIf
    Else
        oExcel:DeActivate()
    EndIf

Return .T.

//--------------------------------------------------
Static Function EnviaEmail(cAnexo, cFilialDe, cFilialAte, cArmazemDe, cArmazemAte, cProdutoDe, cProdutoAte) as variant
Local cPara := ""
/*
    Local oWFProcess := TWFProcess():New('VALRPT01','Saldos em estoque')

    oWFProcess:NewTask('VALRPT01')

    oWFProcess:cTo      := AllTrim(GetNewPar('ZZ_RPTMAIL'))
    oWFProcess:cSubject := 'Saldos em Estoque - ' + DToC(Date())
    oWFProcess:cBody    := 'Olá, segue em anexo relatório de saldos em estoque referente ao dia ' + DToC(Date()) + ', considerando os seguintes paramêtros: ' + CRLF;
                            + 'Filial De: '   + cFilialDe   + CRLF;
                            + 'Filial Ate: '  + cFilialAte  + CRLF;
                            + 'Armazém De: '  + cArmazemDe  + CRLF;
                            + 'Armazém Ate: ' + cArmazemAte + CRLF;
                            + 'Produto De: '  + cProdutoDe  + CRLF;
                            + 'Produto Ate: ' + cProdutoAte + CRLF
    
    oWFProcess:AttachFile(cAnexo)

    oWFProcess:Start()
   
    FreeObj(oWFProcess)
*/
cPara := AllTrim(GetNewPar('ZZ_RPTEMA1'))
cPara += AllTrim(GetNewPar('ZZ_RPTEMA2'))
cMens := 'Olá, segue em anexo relatório de saldos em estoque referente ao dia ' + DToC(Date()) + ', considerando os seguintes paramêtros: ' + CRLF;
            + 'Filial De: '   + cFilialDe   + CRLF;
            + 'Filial Ate: '  + cFilialAte  + CRLF;
            + 'Armazém De: '  + cArmazemDe  + CRLF;
            + 'Armazém Ate: ' + cArmazemAte + CRLF;
            + 'Produto De: '  + cProdutoDe  + CRLF;
            + 'Produto Ate: ' + cProdutoAte + CRLF
u_FUN_EMAIL(cAnexo,'Saldos em Estoque - ' + DToC(Date()),cMens,cPara,"","")

Return

//---------------------------------------------------
Static Function QueryRegs(cFilialDe, cFilialAte, cArmazemDe, cArmazemAte, cProdutoDe, cProdutoAte,lQtdMzero) as character

    Local cQry := ''

    BeginContent var cQry

        SELECT 
            SB2.B2_FILIAL,
            SB1.B1_COD,
            SB1.B1_ZZCOLEC,
            SB1.B1_ZZREFER,
            SB1.B1_ZZLINE,
            SB1.B1_DESC,
            SB1.B1_ZZCOR,
            SB1.B1_ZZTAMAN,
            SB1.B1_CODBAR,
            SB2.B2_QATU,
            SB2.B2_VATU1,
            SB0.B0_PRV1,
            SB1.B1_LOCPAD,
            SB2.B2_LOCALIZ,
            SB2.B2_QNPT
        FROM
            %Exp:RetSqlTab("SB1")%
        INNER JOIN
            %Exp:RetSqltab("SB2")%
                ON
                    SB2.B2_COD = SB1.B1_COD AND %Exp:RetSqlDel("SB1")% 
        LEFT OUTER JOIN
            %Exp:RetSqltab("SB0")%
                ON
                    SB0.B0_COD = SB1.B1_COD AND %Exp:RetSqlDel("SB0")% 
        WHERE
            %Exp:RetSqlDel("SB2")% AND
            SB2.B2_FILIAL BETWEEN '%Exp:cFilialDe%'  AND '%Exp:cFilialAte%'  AND
            SB2.B2_LOCAL  BETWEEN '%Exp:cArmazemDe%' AND '%Exp:cArmazemAte%' AND
            SB2.B2_COD    BETWEEN '%Exp:cProdutoDe%' AND '%Exp:cProdutoAte%' 

    EndContent

//                    SB2.B2_LOCAL = SB1.B1_LOCPAD
//            SB1.B1_LOCPAD BETWEEN '%Exp:cArmazemDe%' AND '%Exp:cArmazemAte%' AND

    If lQtdMzero
        cQry += " AND SB2.B2_QATU <> '0'" 
    EndIf

    cQry += " ORDER BY B2_FILIAL,B1_COD"

Return ChangeQuery(cQry)
/*---------------------------------------------------------------------------*/
/*Static Function SchedDef()
Local aOrd   := {}
Local aParam := { "P"       ,; // Tipo R para relatorio P para processo
                  "PARAMDEF",; // Pergunte do relatorio. Caso nao use passar ParamDef
                  ""        ,; // Alias
                  aOrd      ,; // Array de ordens
                  }

Return aParam
*/
