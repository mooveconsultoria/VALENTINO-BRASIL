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
    Local dEmissaoDe  := FirstDate(Date())
    Local dEmissaoAte := LastDate(Date())
    Local cDtCorte    := SuperGetMV('VA_RPT01DT',,'20241001') // Data de corte para filtro de estoque em transito e terceiro demonstração
    Local cTesDemo    := SuperGetMV('VA_RPT01TE',,"('912','913','914','915')") // TES DE SAIDA DEMONST

    Default lSchedule := .F.

    If !lSchedule
        aAdd(aPergs, {1, "Filial De"       , Space(Len(cFilAnt))       , "", ".T.", "SM0", ".T.", 80, .F.})
        aAdd(aPergs, {1, "Filial Ate"      , Space(Len(cFilAnt))       , "", ".T.", "SM0", ".T.", 80, .F.})
        aAdd(aPergs, {1, "Armazem De"      , Space(TamSX3('B1_COD')[1]), "", ".T.", "NNR", ".T.", 80, .F.})
        aAdd(aPergs, {1, "Armazem Ate"     , Space(TamSX3('B1_COD')[1]), "", ".T.", "NNR", ".T.", 80, .F.})
        aAdd(aPergs, {1, "Produto De"      , Space(TamSX3('B1_COD')[1]), "", ".T.", "SB1", ".T.", 80, .F.})
        aAdd(aPergs, {1, "Produto Ate"     , Space(TamSX3('B1_COD')[1]), "", ".T.", "SB1", ".T.", 80, .F.})
        aAdd(aPergs, {2, "Qtd. Dif. de 0"  , 1                         , {"1=Sim", "2=Não"},90, ".T.", .F.})
        aAdd(aPergs, {1, "Emissão De"      , FirstDate(Date())         , "", ".T.", ""   , ".T.", 80, .F.})
        aAdd(aPergs, {1, "Emissão Ate"     , LastDate(Date())          , "", ".T.", ""   , ".T.", 80, .F.})

        If ParamBox(aPergs, "Informe os parâmetros")
            cFilialDe   := MV_PAR01
            cFilialAte  := MV_PAR02
            cArmazemDe  := MV_PAR03
            cArmazemAte := MV_PAR04
            cProdutoDe  := MV_PAR05
            cProdutoAte := MV_PAR06
            lQtdMzero   := IIF(MV_PAR07 == 1,.T.,.F.)
            dEmissaoDe  := MV_PAR08
            dEmissaoAte := MV_PAR09
        Else
            Return
        EndIf
    EndIf

    cQuery := QueryRegs(AllTrim(cFilialDe), AllTrim(cFilialAte), AllTrim(cArmazemDe), AllTrim(cArmazemAte), AllTrim(cProdutoDe), AllTrim(cProdutoAte),lQtdMzero, dEmissaoDe, dEmissaoAte, cDtCorte, cTesDemo) // Filial De, Filial Até, Armazem De, Armazem Ate, Produto De, Produto Ate

    TcQuery cQuery new Alias (cTMPAlias := GetNextAlias())

    DbSelectArea(cTMPAlias)
    (cTMPAlias)->(DbGoTop())

    oExcel:AddworkSheet(cWorkSheet)
    oExcel:AddTable(cWorkSheet,cTituloWS)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Filial"              , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Código do Produto"   , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Coleção"             , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Referência"          , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "FLAG"                , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Categoria"           , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Details"             , 1, 1)
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
                        '',;
                        '',;
                        '',;
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
                        (cTMPAlias)->B6_SALDO;
                    };
                )
            //EndIf
        (cTMPAlias)->(DbSkip())
    EndDo

    (cTMPAlias)->(DbCloseArea())

    cQuery := QryEstTr(AllTrim(cFilialDe), AllTrim(cFilialAte), AllTrim(cArmazemDe), AllTrim(cArmazemAte), AllTrim(cProdutoDe), AllTrim(cProdutoAte), dEmissaoDe, dEmissaoAte, cDtCorte)

    MpSysOpenQuery(cQuery, cTMPAlias)

    cWorkSheet := "Estoque em Trânsito"
    oExcel:AddworkSheet(cWorkSheet)
    oExcel:AddTable(cWorkSheet,cTituloWS)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Fl Orig"             , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Fl Dest"             , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Código do Produto"   , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Coleção"             , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Referência"          , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "FLAG"                , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Categoria"           , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Details"             , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Linha"               , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Descrição do Produto", 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Cor"                 , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Tamanho"             , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Saldo"               , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Valor em Estoque"    , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Preço de Venda"      , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Total de Venda"      , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Armazém"             , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Descrição do Armazém", 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Saldo em Terceiro"   , 1, 1)

    While (cTMPAlias)->(!Eof())
        oExcel:AddRow(cWorkSheet,cTituloWS,;
            {;
                (cTMPAlias)->F2_FILIAL,;                         // Fl Orig
                (cTMPAlias)->F1_FILIAL,;                         // Fl Dest
                (cTMPAlias)->B1_COD,;                            // Código do Produto
                (cTMPAlias)->B1_ZZCOLEC,;                        // Coleção
                (cTMPAlias)->B1_ZZREFER,;                        // Referência
                '',;                                             // FLAG
                '',;                                             // Categoria
                '',;                                             // Details
                (cTMPAlias)->B1_ZZLINE,;                         // Linha
                (cTMPAlias)->B1_DESC,;                           // Descrição do Produto
                (cTMPAlias)->B1_ZZCOR,;                          // Cor
                (cTMPAlias)->B1_ZZTAMAN,;                        // Tamanho
                (cTMPAlias)->D2_QUANT,;                          // Saldo
                (cTMPAlias)->B2_CM1*(cTMPAlias)->D2_QUANT,;      // Valor em Estoque
                (cTMPAlias)->B0_PRV1,;                           // Preço de Venda
                (cTMPAlias)->B0_PRV1*(cTMPAlias)->D2_QUANT,;     // Total de Venda
                (cTMPAlias)->B1_LOCPAD,;                         // Armazém
                (cTMPAlias)->B2_LOCALIZ,;                        // Descrição do Armazém
                (cTMPAlias)->B6_SALDO;                           // Saldo em Terceiro
            };
        )
        (cTMPAlias)->(DbSkip())
    EndDo

    (cTMPAlias)->(DbCloseArea())

    cQuery := QryEst3(AllTrim(cFilialDe), AllTrim(cFilialAte), AllTrim(cArmazemDe), AllTrim(cArmazemAte), AllTrim(cProdutoDe), AllTrim(cProdutoAte), dEmissaoDe, dEmissaoAte, cDtCorte, cTesDemo)

    MpSysOpenQuery(cQuery, cTMPAlias)

    cWorkSheet := "Estoque em Terceiro"
    oExcel:AddworkSheet(cWorkSheet)
    oExcel:AddTable(cWorkSheet,cTituloWS)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Filial"              , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Código do Produto"   , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Coleção"             , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Referência"          , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "FLAG"                , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Categoria"           , 1, 1)
    oExcel:AddColumn(cWorkSheet,cTituloWS, "Details"             , 1, 1)
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
        oExcel:AddRow(cWorkSheet,cTituloWS,;
            {;
                (cTMPAlias)->B6_FILIAL,;                        // Filial
                (cTMPAlias)->B1_COD,;                           // Código do Produto
                (cTMPAlias)->B1_ZZCOLEC,;                       // Coleção
                (cTMPAlias)->B1_ZZREFER,;                       // Referência
                '',;                                            // FLAG
                '',;                                            // Categoria
                '',;                                            // Details
                (cTMPAlias)->B1_ZZLINE,;                        // Linha
                (cTMPAlias)->B1_DESC,;                          // Descrição do Produto
                (cTMPAlias)->B1_ZZCOR,;                         // Cor
                (cTMPAlias)->B1_ZZTAMAN,;                       // Tamanho
                (cTMPAlias)->B1_CODBAR,;                        // Código de Barras
                (cTMPAlias)->B6_SALDO,;                         // Saldo Atual
                (cTMPAlias)->B2_CM1*(cTMPAlias)->B6_SALDO,;     // Valor em Estoque
                (cTMPAlias)->B0_PRV1,;                          // Preço de Venda
                (cTMPAlias)->B0_PRV1*(cTMPAlias)->B6_SALDO,;    // Total de Venda
                (cTMPAlias)->B1_LOCPAD,;                        // Armazém
                (cTMPAlias)->B2_LOCALIZ,;                       // Descrição do Armazém
                (cTMPAlias)->B6_SALDO;                          // Saldo em Terceiro
            };
        )
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
Static Function QueryRegs(cFilialDe, cFilialAte, cArmazemDe, cArmazemAte, cProdutoDe, cProdutoAte,lQtdMzero, dEmissaoDe, dEmissaoAte, cDtCorte, cTesDemo) as character

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
            SUM(ISNULL(SB6.B6_SALDO, 0)) B6_SALDO
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
        LEFT JOIN
            %Exp:RetSqltab("SB6")%
                ON
                    SB6.B6_FILIAL = SB2.B2_FILIAL AND
                    SB6.B6_PRODUTO = SB2.B2_COD AND
                    SB6.B6_EMISSAO >= '%Exp:cDtCorte%' AND
                    SB6.B6_EMISSAO BETWEEN '%Exp:DTOS(dEmissaoDe)%' AND '%Exp:DTOS(dEmissaoAte)%' AND
                    SB6.B6_TES IN %Exp:cTesDemo% AND
                    SB6.B6_PODER3 = 'R' AND %Exp:RetSqlDel("SB6")% 
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

    cQry += "GROUP BY SB2.B2_FILIAL, "
    cQry += "   SB1.B1_COD, "
    cQry += "   SB1.B1_ZZCOLEC, "
    cQry += "   SB1.B1_ZZREFER, "
    cQry += "   SB1.B1_ZZLINE, "
    cQry += "   SB1.B1_DESC, "
    cQry += "   SB1.B1_ZZCOR, "
    cQry += "   SB1.B1_ZZTAMAN, "
    cQry += "   SB1.B1_CODBAR, "
    cQry += "   SB2.B2_QATU, "
    cQry += "   SB2.B2_VATU1, "
    cQry += "   SB0.B0_PRV1, "
    cQry += "   SB1.B1_LOCPAD, "
    cQry += "   SB2.B2_LOCALIZ "

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

/*/{Protheus.doc} QryEstTr
Realiza a consulta do estoque em trânsito.
@type function
@version 12.1.2310
@author Douglas Telles
@since 15/04/2025
@param cFilialDe, character, Filial inicial para o filtro
@param cFilialAte, character, Filial final para o filtro
@param cArmazemDe, character, Armazém inicial para o filtro
@param cArmazemAte, character, Armazém final para o filtro
@param cProdutoDe, character, Produto inicial para o filtro
@param cProdutoAte, character, Produto final para o filtro
@param dEmissaoDe, date, Data de emissão inicial para o filtro
@param dEmissaoAte, date, Data de emissão final para o filtro
@param cDtCorte, character, Data de corte para o filtro no formato 'YYYYMMDD'
@return character, Retorna uma string com a consulta a ser realizada no banco de dados.
/*/
Static Function QryEstTr(cFilialDe, cFilialAte, cArmazemDe, cArmazemAte, cProdutoDe, cProdutoAte, dEmissaoDe, dEmissaoAte, cDtCorte)
    Local cQry      := ''

    Default cFilialDe   := ""
    Default cFilialAte  := ""
    Default cArmazemDe  := ""
    Default cArmazemAte := ""
    Default cProdutoDe  := ""
    Default cProdutoAte := ""
    Default dEmissaoDe  := FirstDate(Date())
    Default dEmissaoAte := LastDate(Date())
    Default cDtCorte    := '20241001'

    cQry := "SELECT SF2.F2_FILIAL " + CRLF
    cQry += "    ,ISNULL(SF1.F1_FILIAL, '') F1_FILIAL " + CRLF
    cQry += "    ,SB1.B1_COD " + CRLF
    cQry += "    ,SB1.B1_ZZCOLEC " + CRLF
    cQry += "    ,SB1.B1_ZZREFER " + CRLF
    cQry += "    ,SB1.B1_ZZLINE " + CRLF
    cQry += "    ,SB1.B1_DESC " + CRLF
    cQry += "    ,SB1.B1_ZZCOR " + CRLF
    cQry += "    ,SB1.B1_ZZTAMAN " + CRLF
    cQry += "    ,SUM(SD2.D2_QUANT) D2_QUANT " + CRLF
    cQry += "    ,SB2.B2_CM1 " + CRLF
    cQry += "    ,SB0.B0_PRV1 " + CRLF
    cQry += "    ,SB1.B1_LOCPAD " + CRLF
    cQry += "    ,SB2.B2_LOCALIZ " + CRLF
    cQry += "    ,0 B6_SALDO " + CRLF
    cQry += "FROM " + RetSqlName("SF2") + " SF2 (NOLOCK) " + CRLF
    cQry += "INNER JOIN " + RetSqlName("SA1") + " SA1 (NOLOCK) " + CRLF
    cQry += "    ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF
    cQry += "    AND SA1.A1_COD = SF2.F2_CLIENTE " + CRLF
    cQry += "    AND SA1.A1_LOJA = SF2.F2_LOJA " + CRLF
    cQry += "    AND SA1.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "INNER JOIN SYS_COMPANY SM0 (NOLOCK) " + CRLF
    cQry += "    ON SM0.M0_CGC = SA1.A1_CGC " + CRLF
    cQry += "    AND SM0.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "INNER JOIN " + RetSqlName("SD2") + " SD2 (NOLOCK) " + CRLF
    cQry += "    ON SD2.D2_FILIAL = SF2.F2_FILIAL " + CRLF
    cQry += "    AND SD2.D2_DOC = SF2.F2_DOC " + CRLF
    cQry += "    AND SD2.D2_SERIE = SF2.F2_SERIE " + CRLF
    cQry += "    AND SD2.D2_CLIENTE = SF2.F2_CLIENTE " + CRLF
    cQry += "    AND SD2.D2_LOJA = SF2.F2_LOJA " + CRLF
    cQry += "    AND SD2.D2_COD BETWEEN '" + cProdutoDe + "' AND '" + cProdutoAte + "'  " + CRLF
    cQry += "    AND SD2.D2_LOCAL BETWEEN '" + cArmazemDe + "' AND '" + cArmazemAte + "'  " + CRLF
    cQry += "    AND SD2.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) " + CRLF
    cQry += "    ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
    cQry += "    AND SB1.B1_COD = SD2.D2_COD " + CRLF
    cQry += "    AND SB1.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "INNER JOIN " + RetSqlName("SB2") + " SB2 (NOLOCK) " + CRLF
    cQry += "    ON SB2.B2_FILIAL = SD2.D2_FILIAL " + CRLF
    cQry += "    AND SB2.B2_COD = SD2.D2_COD " + CRLF
    cQry += "    AND SB2.B2_LOCAL = SD2.D2_LOCAL " + CRLF
    cQry += "    AND SB2.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "INNER JOIN " + RetSqlName("SB0") + " SB0 (NOLOCK) " + CRLF
    cQry += "    ON SB0.B0_FILIAL = '" + xFilial("SB0") + "' " + CRLF
    cQry += "    AND SB0.B0_COD = SD2.D2_COD " + CRLF
    cQry += "    AND SB0.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "INNER JOIN " + RetSqlName("SF1") + " SF1 (NOLOCK) " + CRLF
    cQry += "    ON SF1.F1_FILIAL = SM0.M0_CODFIL " + CRLF
    cQry += "    AND SF1.F1_DOC = SF2.F2_DOC " + CRLF
    cQry += "    AND SF1.F1_SERIE = SF2.F2_SERIE " + CRLF
    cQry += "    AND SF1.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "INNER JOIN " + RetSqlName("SD1") + " SD1 (NOLOCK) " + CRLF
    cQry += "    ON SD1.D1_FILIAL = SF1.F1_FILIAL " + CRLF
    cQry += "    AND SD1.D1_DOC = SF1.F1_DOC " + CRLF
    cQry += "    AND SD1.D1_SERIE = SF1.F1_SERIE " + CRLF
    cQry += "    AND SD1.D1_FORNECE = SF1.F1_FORNECE " + CRLF
    cQry += "    AND SD1.D1_LOJA = SF1.F1_LOJA " + CRLF
    cQry += "    AND SD1.D1_COD = SD2.D2_COD " + CRLF
    cQry += "    AND SD1.D1_LOCAL = SD2.D2_LOCAL " + CRLF
    cQry += "    AND SD1.D1_TES = '' " + CRLF
    cQry += "    AND SD1.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "WHERE SF2.F2_FILIAL BETWEEN '" + cFilialDe + "'  AND '" + cFilialAte + "' " + CRLF
    cQry += "    AND SF2.F2_EMISSAO BETWEEN '" + DTOS(dEmissaoDe) + "' AND '" + DTOS(dEmissaoAte) + "' " + CRLF
    cQry += "    AND SF2.F2_EMISSAO >= '" + cDtCorte + "' " + CRLF
    cQry += "    AND SF2.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "GROUP BY " + CRLF
    cQry += "    SF2.F2_FILIAL, " + CRLF
    cQry += "    ISNULL(SF1.F1_FILIAL, ''), " + CRLF
    cQry += "    SB1.B1_COD, " + CRLF
    cQry += "    SB1.B1_ZZCOLEC, " + CRLF
    cQry += "    SB1.B1_ZZREFER, " + CRLF
    cQry += "    SB1.B1_ZZLINE, " + CRLF
    cQry += "    SB1.B1_DESC, " + CRLF
    cQry += "    SB1.B1_ZZCOR, " + CRLF
    cQry += "    SB1.B1_ZZTAMAN, " + CRLF
    cQry += "    SB2.B2_CM1, " + CRLF
    cQry += "    SB0.B0_PRV1, " + CRLF
    cQry += "    SB1.B1_LOCPAD, " + CRLF
    cQry += "    SB2.B2_LOCALIZ " + CRLF
Return ChangeQuery(cQry)

/*/{Protheus.doc} QryEst3
Realiza a consulta do estoque em poder de terceiro.
@type function
@version 12.1.2310
@author Douglas Telles
@since 15/04/2025
@param cFilialDe, character, Filial inicial para o filtro
@param cFilialAte, character, Filial final para o filtro
@param cArmazemDe, character, Armazém inicial para o filtro
@param cArmazemAte, character, Armazém final para o filtro
@param cProdutoDe, character, Produto inicial para o filtro
@param cProdutoAte, character, Produto final para o filtro
@param dEmissaoDe, date, Data de emissão inicial para o filtro
@param dEmissaoAte, date, Data de emissão final para o filtro
@param cDtCorte, character, Data de corte para o filtro no formato 'YYYYMMDD'
@param cTesDemo, character, Código das TES para filtrar notas de demonstração
@return character, Retorna uma string com a consulta a ser realizada no banco de dados.
/*/
Static Function QryEst3(cFilialDe, cFilialAte, cArmazemDe, cArmazemAte, cProdutoDe, cProdutoAte, dEmissaoDe, dEmissaoAte, cDtCorte, cTesDemo)
    Local cQry      := ''

    Default cFilialDe   := ""
    Default cFilialAte  := ""
    Default cArmazemDe  := ""
    Default cArmazemAte := ""
    Default cProdutoDe  := ""
    Default cProdutoAte := ""
    Default dEmissaoDe  := FirstDate(Date())
    Default dEmissaoAte := LastDate(Date())
    Default cDtCorte    := '20241001'
    Default cTesDemo    := "('912','913','914','915')"

    cQry := "SELECT SB6.B6_FILIAL " + CRLF
    cQry += "   ,SB1.B1_COD " + CRLF
    cQry += "   ,SB1.B1_ZZCOLEC " + CRLF
    cQry += "   ,SB1.B1_ZZREFER " + CRLF
    cQry += "   ,SB1.B1_ZZLINE " + CRLF
    cQry += "   ,SB1.B1_DESC " + CRLF
    cQry += "   ,SB1.B1_ZZCOR " + CRLF
    cQry += "   ,SB1.B1_ZZTAMAN " + CRLF
    cQry += "   ,SB1.B1_CODBAR " + CRLF
    cQry += "   ,SUM(SB6.B6_SALDO) B6_SALDO " + CRLF
    cQry += "   ,SB2.B2_CM1 " + CRLF
    cQry += "   ,SB0.B0_PRV1 " + CRLF
    cQry += "   ,SB1.B1_LOCPAD " + CRLF
    cQry += "   ,SB2.B2_LOCALIZ " + CRLF
    cQry += "FROM " + RetSqlName("SB6") + " SB6 (NOLOCK) " + CRLF
    cQry += "INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) " + CRLF
    cQry += "    ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
    cQry += "    AND SB1.B1_COD = SB6.B6_PRODUTO " + CRLF
    cQry += "    AND SB1.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "INNER JOIN " + RetSqlName("SB2") + " SB2 (NOLOCK) " + CRLF
    cQry += "    ON SB2.B2_FILIAL = SB6.B6_FILIAL " + CRLF
    cQry += "    AND SB2.B2_COD = SB6.B6_PRODUTO " + CRLF
    cQry += "    AND SB2.B2_LOCAL BETWEEN '" + cArmazemDe + "' AND '" + cArmazemAte + "' " + CRLF
    cQry += "    AND SB2.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "INNER JOIN " + RetSqlName("SB0") + " SB0 (NOLOCK) " + CRLF
    cQry += "    ON SB0.B0_FILIAL = '" + xFilial("SB0") + "' " + CRLF
    cQry += "    AND SB0.B0_COD = SB6.B6_PRODUTO " + CRLF
    cQry += "    AND SB0.D_E_L_E_T_ = ' ' " + CRLF
    cQry += "WHERE SB6.B6_FILIAL BETWEEN '" + cFilialDe + "'  AND '" + cFilialAte + "' " + CRLF
    cQry += "    AND SB6.B6_PRODUTO BETWEEN '" + cProdutoDe + "' AND '" + cProdutoAte + "' " + CRLF
    cQry += "    AND SB6.B6_PODER3 = 'R' " + CRLF
    cQry += "    AND SB6.B6_SALDO > 0 " + CRLF
    cQry += "    AND SB6.B6_TES IN " + cTesDemo + CRLF
    cQry += "    AND SB6.B6_EMISSAO >= '" + cDtCorte + "' " + CRLF
    cQry += "    AND SB6.B6_EMISSAO BETWEEN '" + DTOS(dEmissaoDe) + "' AND '" + DTOS(dEmissaoAte) + "' " + CRLF
    cQry += "    AND SB6.D_E_L_E_T_ = '' " + CRLF
    cQry += "GROUP BY SB6.B6_FILIAL " + CRLF
    cQry += "   ,SB1.B1_COD " + CRLF
    cQry += "   ,SB1.B1_ZZCOLEC " + CRLF
    cQry += "   ,SB1.B1_ZZREFER " + CRLF
    cQry += "   ,SB1.B1_ZZLINE " + CRLF
    cQry += "   ,SB1.B1_DESC " + CRLF
    cQry += "   ,SB1.B1_ZZCOR " + CRLF
    cQry += "   ,SB1.B1_ZZTAMAN " + CRLF
    cQry += "   ,SB1.B1_CODBAR " + CRLF
    cQry += "   ,SB2.B2_CM1 " + CRLF
    cQry += "   ,SB0.B0_PRV1 " + CRLF
    cQry += "   ,SB1.B1_LOCPAD " + CRLF
    cQry += "   ,SB2.B2_LOCALIZ " + CRLF
Return ChangeQuery(cQry)
