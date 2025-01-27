#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RwMake.ch"
#include 'tbiconn.ch'



/*
* Funcao		:	RHACUCOMP
* Autor			:	Tiago Maniero
* Data			: 	19/05/2021
* Descricao		:	Relatório RH Valores acumulados por competencia
*/
user function RHACUCOMP()
    private aVerbas := {}

    if perg()   
        aVerbas := u_telaVerbas()
        if len(aVerbas) > 0
            FwMsgRun( Nil , { || montaExcel() } , 'Processando' , "Gerando Relatório...   " )
        endif
    endif

return

//Caixa de parametros
static function perg()
    local lRet      := .F.
    local aParamBox	:= {}
    local cPerg   := "Parametros de Planilha Valores Acumulados"


    aAdd(aParamBox  ,{1,"Período"             ,Space(GetSx3Cache("RCH_PER","X3_TAMANHO"))  ,"","","RCH"   ,"", 6,.T.})  		 	
    aAdd(aParamBox  ,{1,"Filial De"           ,Space(GetSx3Cache("RA_FILIAL","X3_TAMANHO")),"","","SM0EMP","", 6,.F.})  		 	
    aAdd(aParamBox  ,{1,"Filial Ate"          ,Space(GetSx3Cache("RA_FILIAL","X3_TAMANHO")),"","","SM0EMP","", 6,.T.})  		 	
    aAdd(aParamBox  ,{1,"Centro de Custo De"  ,Space(GetSx3Cache("CTT_CUSTO","X3_TAMANHO")),"","","CTT"   ,"", 6,.F.})  		 	
    aAdd(aParamBox  ,{1,"Centro de Custo Ate" ,Space(GetSx3Cache("CTT_CUSTO","X3_TAMANHO")),"","","CTT"   ,"", 6,.T.})
    aAdd(aParamBox  ,{1,"Matrícula De"        ,Space(GetSx3Cache("RA_MAT","X3_TAMANHO"))   ,"","","SRA"   ,"", 6,.F.})  		 	
    aAdd(aParamBox  ,{1,"Matrícula Ate"       ,Space(GetSx3Cache("RA_MAT","X3_TAMANHO"))   ,"","","SRA"   ,"", 6,.T.})
    aAdd(aParamBox  ,{1,"Roteiro"             ,Space(GetSx3Cache("RC_ROTEIR","X3_TAMANHO")),"","","SRYRES","", 6,.T.})
    aAdd(aParamBox  ,{1,"Processo"            ,Space(GetSx3Cache("RC_PROCES","X3_TAMANHO")),"","","RCJ"      ,"", 6,.T.})


return ParamBox(aParamBox,"Planilha Valores Acumulados por Competência",,,,,,,,cPerg,.F.,.F.)

//Inicia criação do excel se confirmados registros
static function montaExcel()
    local cAlias := ProcDados()
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

//Query para pesquisa de contas
static function ProcDados()
    local cQuery  := ""
    local cAlias  := getNextAlias()
    local cNomVer := colVerbas(1)
    local cFilVer := colVerbas(2)


    cQuery += "SELECT RA_FILIAL, RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST " + CRLF
    cQuery += ","+cNomVer + CRLF
    cQuery += " FROM(" + CRLF
    cQuery += " SELECT RA_FILIAL, RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST " + CRLF
    cQuery += " ,RV_COD VERBA , SUM(RC_VALOR) VALOR " + CRLF
    cQuery += " FROM " + retSqlTab("SRA") + CRLF
    cQuery += "  INNER JOIN " + retSqlTab("SRC") + CRLF
    cQuery += "   ON RC_FILIAL = RA_FILIAL " + CRLF
    cQuery += "   AND RC_MAT = RA_MAT " + CRLF
    cQuery += "   AND RC_PERIODO = '" + MV_PAR01 + "' " + CRLF
    cQuery += "   AND SRC.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  INNER JOIN "+ retSqlTab("SRV") + CRLF
    cQuery += "   ON RV_FILIAL = '" + xfilial("SRV") +"' " + CRLF
    cQuery += "   AND RV_COD = RC_PD " + CRLF
    cQuery += "   AND RV_COD IN ("+cFilVer+") " + CRLF
    cQuery += "   AND SRV.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  WHERE RA_FILIAL BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' " + CRLF
    cQuery += "   AND RA_MAT BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' " + CRLF
    cQuery += "   AND RA_CC BETWEEN '"+ MV_PAR04 + "' AND '" + MV_PAR05 + "' " + CRLF
    cQuery += "   AND SRA.D_E_L_E_T_ = '' " + CRLF
    cQuery += " GROUP BY  RA_FILIAL, RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST,RV_COD ) C " + CRLF
    cQuery += " PIVOT(SUM(VALOR) FOR VERBA IN (" + cNomVer + "))  P " + CRLF
    cQuery += " UNION " + CRLF
    cQuery += "SELECT RA_FILIAL, RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST " + CRLF
    cQuery += ","+cNomVer + CRLF
    cQuery += " FROM(" + CRLF
    cQuery += " SELECT RA_FILIAL, RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST " + CRLF
    cQuery += " ,RV_COD VERBA , SUM(RD_VALOR) VALOR " + CRLF
    cQuery += " FROM " + retSqlTab("SRA") + CRLF
    cQuery += "  INNER JOIN " + retSqlTab("SRD") + CRLF
    cQuery += "   ON RD_FILIAL = RA_FILIAL " + CRLF
    cQuery += "   AND RD_MAT = RA_MAT " + CRLF
    cQuery += "   AND SUBSTRING(RD_DATPGT,1,6) = '" + MV_PAR01 + "' " + CRLF
    cQuery += "   AND SRD.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  INNER JOIN " + retSqlTab("SRV") + CRLF
    cQuery += "   ON RV_FILIAL = '" + xFilial("SRV") + "' " + CRLF
    cQuery += "   AND RV_COD = RD_PD " + CRLF
    cQuery += "   AND RV_COD IN ("+cFilVer+") " + CRLF
    cQuery += "   AND SRV.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  WHERE RA_FILIAL BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' " + CRLF
    cQuery += "   AND RA_MAT BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' " + CRLF
    cQuery += "   AND RA_CC BETWEEN '"+ MV_PAR04 + "' AND '" + MV_PAR05 + "' " + CRLF
    cQuery += "   AND SRA.D_E_L_E_T_ = '' " + CRLF
    cQuery += " GROUP BY  RA_FILIAL, RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST,RV_COD ) C " + CRLF
    cQuery += " PIVOT(SUM(VALOR) FOR VERBA IN (" + cNomVer + "))  P " + CRLF
        
    tcQuery cQuery new alias &cAlias


Return cAlias


static function colVerbas(nFlag)
    local nI   := 1
    local cRet := ""
    

    for nI := 1 to len(aVerbas)
        if nFlag == 1
            cRet += "["+aVerbas[nI,1]+"]"
        else
            cRet += "'"+aVerbas[nI,1]+"'"
        endif

        if nI <> len(aVerbas)
            cRet += ","
        endif
    next nI


return cRet


//Preenche array que irá para a planilha
static function montaDados(cAlias)
    local aRet := {}
    local aAux := {}
    local nI   := 1


    while (cAlias)->(!eof())
        aAdd(aAux,(cAlias)->RA_FILIAL)
        aAdd(aAux,(cAlias)->RA_MAT)
        aAdd(aAux,(cAlias)->RA_NOMECMP)
        aAdd(aAux,(cAlias)->RA_ZZID)
        for nI := 1 to len(aVerbas)
            aAdd(aAux,fieldget(fieldpos(FIELD(nI+5))))
        next nI
        aAdd(aRet,aAux)
        aAux := {}
        (cAlias)->(dbSkip())
    endDo
    (cAlias)->(dbCloseArea())

return aRet

//População da planilha
static function criaPlanilha(aDados,cDir)
    local oExcel    := FWMsExcel():New()
    local cTitulo   := "Relatório Valores Acumulados por Competência"
    local cTable    := cTitulo
    local cTitulo2  := "Período " + MV_PAR01
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

    oExcel:AddColumn(cPlanilha, cTable, "FILIAL"             , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "MATRICULA"          , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "NOME"               , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "ZID"                , 1, 1)
    for nI := 1 to len(aVerbas)
        oExcel:AddColumn(cPlanilha, cTable, aVerbas[nI,1] + "-" + aVerbas[nI,2], 1, 2)
    next nI

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



