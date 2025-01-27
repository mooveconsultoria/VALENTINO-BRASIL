#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RwMake.ch"
#include 'tbiconn.ch'



/*
* Funcao		:	PROVFERIAS
* Autor			:	Tiago Maniero
* Data			: 	26/05/2021
* Descricao		:	Relatório RH Provisão de férias
*/
user function PROVFERIAS()
    local cAlias := procDados()
    local aDados := {}
    local cDir   := nil
    
    
    if (cAlias)->(!eof())
        cDir := cGetFile('*.xls|*.xls',"Selecione diretório",,,.F.,GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY  ,.T.)
        if !empty(cDir)
            aDados := montaDados(cAlias)
            criaPlanilha(aDados,cDir)
        endif    
    else
        msgAlert("Não há registros para os parâmetros selecionados. Impressão será cancelada.")
    endif


return

//Consulta fazendo pivot para trazer as verbas a calcular
static function procDados()
    local cQuery := ""
    local cAlias := getNextAlias()


    cQuery += "SELECT RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST, RT_DATACAL, RT_TIPPROV , RT_DFERVEN  " + CRLF
    cQuery += " ,[830] AS VALOR, [831] AS ADICIONAIS, [832] AS TERCOFERIAS, [833] AS INSS, [834] AS FGTS " + CRLF
    cQuery += " FROM( " + CRLF
    cQuery += " SELECT RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST, RT_VERBA VERBA, RT_DATACAL, RT_TIPPROV , RT_DFERVEN, SUM(RT_VALOR) VALOR2 " + CRLF
    cQuery += "  FROM " + retSqlTab("SRA") + CRLF
    cQuery += "  INNER JOIN " + retSqlTab("SRT") + CRLF
    cQuery += "   ON RA_FILIAL = RT_FILIAL " + CRLF
    cQuery += "   AND RA_MAT = RT_MAT " + CRLF
    cQuery += "   AND RT_DATACAL = '" + dtos(lastday(MV_PAR01)) + "' " + CRLF
    cQuery += "   AND RT_VERBA IN ('830','831','832','833','834') " + CRLF
    cQuery += "   AND SRT.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  WHERE RA_FILIAL BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' " + CRLF
    cQuery += "   AND RA_MAT BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' " + CRLF
    cQuery += "   AND RA_CC BETWEEN '"+ MV_PAR04 + "' AND '" + MV_PAR05 + "' " + CRLF
    cQuery += "   AND SRA.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  GROUP BY RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST, RT_VERBA, RT_DATACAL, RT_TIPPROV , RT_DFERVEN) C " + CRLF
    cQuery += "  PIVOT(SUM(VALOR2) FOR VERBA IN ([830], [831], [832], [833], [834])) P " + CRLF

    tcQuery cQuery new alias &cAlias


return cAlias


static function montaDados(cAlias)
    local aRet := {}


    while (cAlias)->(!eof())
        if(cAlias)->RT_TIPPROV == "1"
            linhaAtual(cAlias,@aRet,"Vencidas") 
        else
            linhaAtual(cAlias,@aRet,"A Avencer") 
        endif
        (cAlias)->(dbSkip())
    endDo


return aRet


static function linhaAtual(cAlias,aRet,cMessage)
    local nTotVerbas := (cAlias)->VALOR+(cAlias)->ADICIONAIS+(cAlias)->TERCOFERIAS
    local nEncargos  := (cAlias)->INSS+(cAlias)->FGTS
    local nTotal     := (cAlias)->VALOR+(cAlias)->ADICIONAIS+(cAlias)->TERCOFERIAS+(cAlias)->INSS+(cAlias)->FGTS
    local aAux       := {}

    aAdd(aAux,(cAlias)->RA_MAT)
    aAdd(aAux,(cAlias)->RA_NOMECMP)
    aAdd(aAux,(cAlias)->RA_ZZCOST)
    aAdd(aAux,cMessage)
    aAdd(aAux,(cAlias)->VALOR)
    aAdd(aAux,(cAlias)->ADICIONAIS)
    aAdd(aAux,(cAlias)->TERCOFERIAS)
    aAdd(aAux,nTotVerbas)
    aAdd(aAux,(cAlias)->INSS)
    aAdd(aAux,(cAlias)->FGTS)
    aAdd(aAux,nEncargos)
    aAdd(aAux,nTotal)

    aAdd(aRet,aAux)


return

//Geração de planilha
static function criaPlanilha(aDados,cDir)
    local oExcel    := FWMsExcel():New()
    local cTitulo   := "Relatório Provisão"
    local cTable    := cTitulo
    // local cTitulo2  := "Período " + MV_PAR01
    local cPlanilha := "Dados"
    local nI        := 1


    criaAba(oExcel,cTitulo)

    for nI := 1 to len(aDados)
        oExcel:AddRow(cPlanilha,cTable, aDados[nI])
    next nI

    GeraRel(oExcel,cDir, cTitulo)

return

//Criação dos campos da planilha
static function criaAba(oExcel,cTitulo)
    local cTable    := cTitulo
    local cPlanilha := "Dados"
    local nI        := 1

    oExcel:AddWorkSheet(cPlanilha)

    oExcel:AddTable (cPlanilha, cTable)

    oExcel:AddColumn(cPlanilha, cTable, "MATRICULA"          , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "NOME"               , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "CENTRO CUSTO"       , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "REFERENCIA"         , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "VALOR"              , 1, 2)
    oExcel:AddColumn(cPlanilha, cTable, "ADICIONAIS"         , 1, 2)
    oExcel:AddColumn(cPlanilha, cTable, "1/3 CONSTIT"        , 1, 2)
    oExcel:AddColumn(cPlanilha, cTable, "TOTAL FERIAS"       , 1, 2)
    oExcel:AddColumn(cPlanilha, cTable, "INSS"               , 1, 2)
    oExcel:AddColumn(cPlanilha, cTable, "FGTS"               , 1, 2)
    oExcel:AddColumn(cPlanilha, cTable, "TOT.ENCARGOS"       , 1, 2)
    oExcel:AddColumn(cPlanilha, cTable, "TOT.GERAL"          , 1, 2)
    

return

//Geração do relatório em diretório especificado
Static Function GeraRel(oExcel, cDir, cTitulo)
    Local oExcelApp

    If !lIsDir(cDir)
        MontaDir(cDir)
    Endif

    oExcel:Activate()
    cArq := CriaTrab(Nil, .F.) + ".xml"
    oExcel:GetXMLFile(cArq)
    oExcel:DeActivate()

    // if __CopyFile( cArq, cDir + strTran(cTitulo,"xml","xls"))
    if __CopyFile( cArq, cDir + cTitulo+".xls")
        oExcelApp := MsExcel():New()
        oExcelApp:WorkBooks:Open( cDir + cTitulo + ".xls" )
        oExcelApp:SetVisible(.T.)
    endif

Return

