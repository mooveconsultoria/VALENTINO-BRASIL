#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RwMake.ch"
#include 'tbiconn.ch'



/*
* Funcao		:	PROVDECIMO
* Autor			:	Tiago Maniero
* Data			: 	26/05/2021
* Descricao		:	Relatório RH Provisão de 13 salario
*/
user function PROVDECIMO()
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

//Consulta fazendo pivot para pegar as verbas
static function procDados()
    local cQuery := ""
    local cAlias := getNextAlias()


    cQuery += "SELECT RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST, RT_DATACAL " + CRLF
    cQuery += " ,[845] AS VALOR, [846] AS ADICIONAIS, [853] AS PARCELA13, [847] AS INSS, [848] AS FGTS " + CRLF
    cQuery += " FROM( " + CRLF
    cQuery += " SELECT RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST, RT_VERBA VERBA, RT_DATACAL, SUM(RT_VALOR) VALOR2 " + CRLF
    cQuery += "  FROM " + retSqlTab("SRA") + CRLF
    cQuery += "  INNER JOIN " + retSqlTab("SRT") + CRLF
    cQuery += "   ON RA_FILIAL = RT_FILIAL " + CRLF
    cQuery += "   AND RA_MAT = RT_MAT " + CRLF
    cQuery += "   AND RT_DATACAL = '" + dtos(lastday(MV_PAR01)) + "' " + CRLF
    cQuery += "   AND RT_VERBA IN ('845','846','853','847','848') " + CRLF
    cQuery += "   AND SRT.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  WHERE RA_FILIAL BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' " + CRLF
    cQuery += "   AND RA_MAT BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' " + CRLF
    cQuery += "   AND RA_CC BETWEEN '"+ MV_PAR04 + "' AND '" + MV_PAR05 + "' " + CRLF
    cQuery += "   AND SRA.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  GROUP BY RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST, RT_VERBA, RT_DATACAL) C " + CRLF
    cQuery += "  PIVOT(SUM(VALOR2) FOR VERBA IN ([845], [846], [853], [847], [848])) P " + CRLF

    tcQuery cQuery new alias &cAlias


return cAlias

//Função para montar array que irá preencher a planilha
static function montaDados(cAlias)
    local aRet := {}
    local cAnt := ""

    
    while (cAlias)->(!eof())  
        linhaAtual(cAlias,@aRet,"13 Salario")
        (cAlias)->(dbSkip())
    endDo
    (cAlias)->(dbCloseArea())


return aRet

//Função para cálculos de provisão mês anterior e totalizador. cMessage vai receber o identificador da linha(Anterior ou Atual)
static function linhaAtual(cAlias,aRet,cMessage)
    local nTotVerbas := (cAlias)->VALOR+(cAlias)->ADICIONAIS+(cAlias)->PARCELA13
    local nEncargos  := (cAlias)->INSS+(cAlias)->FGTS
    local nTotal     := (cAlias)->VALOR+(cAlias)->ADICIONAIS+(cAlias)->PARCELA13+(cAlias)->INSS+(cAlias)->FGTS
    local aAux       := {}

    aAdd(aAux,(cAlias)->RA_MAT)
    aAdd(aAux,(cAlias)->RA_NOMECMP)
    aAdd(aAux,(cAlias)->RA_ZZCOST)
    aAdd(aAux,cMessage)
    aAdd(aAux,(cAlias)->VALOR)
    aAdd(aAux,(cAlias)->ADICIONAIS)
    aAdd(aAux,(cAlias)->PARCELA13)
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
    local cTitulo2  := "Período " 
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
    oExcel:AddColumn(cPlanilha, cTable, "1 PARCELA"          , 1, 2)
    oExcel:AddColumn(cPlanilha, cTable, "TOTAL 13º"          , 1, 2)
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



