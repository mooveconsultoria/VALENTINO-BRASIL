#INCLUDE "Protheus.ch"
#include "Topconn.ch"
/*----------------------------------------------------------------------------*
* Relatorio de comissoes por vendedor                                         *
* Autor: Oscar Lira - TOTVS IP                       11/07/2023               *
*-----------------------------------------------------------------------------*/
User Function VAFATR01()
Local oReport
Local aParamBox	:= {}
Local aRetPer	:= {}
Private cPerg := ""
Private cNewAlias := GetNextAlias()
Private cCadastro := "Comissões"
Private cFilNome  := ""

aAdd(aParamBox,{1,"Filial de"   ,Space(TamSX3("E3_FILIAL")[1]),"","","SM0","",TamSX3("E3_FILIAL")[1],.F.})  // MV_PAR01
aAdd(aParamBox,{1,"Filial ate"  ,Space(TamSX3("E3_FILIAL")[1]),"","","SM0","",TamSX3("E3_FILIAL")[1],.F.})  // MV_PAR02
aAdd(aParamBox,{1,"Data de"     ,dDataBase                    ,"","",""   ,"",                    60,.F.})  // MV_PAR03
aAdd(aParamBox,{1,"Data ate"    ,dDataBase                    ,"","",""   ,"",                    60,.F.})  // MV_PAR04
aAdd(aParamBox,{1,"Vendedor de" ,Space(TamSX3("A3_COD")[1])   ,"","","SA3","",TamSX3("A3_COD")[1]   ,.F.})  // MV_PAR05
aAdd(aParamBox,{1,"Vendedor ate",Space(TamSX3("A3_COD")[1])   ,"","","SA3","",TamSX3("A3_COD")[1]   ,.F.})  // MV_PAR06

If ParamBox(aParamBox,"Relatório de comissões",@aRetPer,{|| ValParam()})
    oReport := ReportDef()
    oReport:PrintDialog()
EndIf

Return Nil
/*---------------------------------------------------------------------------*/
Static Function ReportDef()
Local oReport,oVendedor,oItens

//oReport := TReport():New(cReport,cTitle,uParam,bAction,cDescription,lLandscape,uTotalText,lTotalInLine,cPageTText,lPageTInLine,lTPageBreak,nColSpace)
oReport := TReport():New("VAFATR01","Comissoes s/ Liquidacao",cPerg,{|oReport| PrintReport(oReport)},;
								 "Este relatório irá imprimir as comissões por vendedor de acordo com parâmetros solicitados.",.T.,,.F.)
oReport:lDisableOrientation := .T.  // Orientação (Retrato/Paisagem) nao podera ser modificada

/*oCliente := TRSection():New(oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,;
										lLineBreak,nLeftMargin,lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)*/


oVendedor := TRSection():New(oReport /*oParent*/,"Filial" /*cTitle*/,{} /*uTable*/,/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/,/*uTotalText*/,;
							 .F. /*lTotalInLine*/,.F. /*lHeaderPage*/,.F. /*lHeaderBreak*/,/*lPageBreak*/,/*lLineBreak*/,/*nLeftMargin*/,;
							 .T. /*lLineStyle*/,/*nColSpace*/,.T. /*lAutoSize*/,/*cCharSeparator*/,/*nLinesBefore*/,/*nCols*/,/*nClrBack*/,/*nClrFore*/,/*nPercentage*/)

//oVendedor := TRSection():New(oReport,"Vendedor",{},,,,"Total Geral",.F.,.F.,,,,,,,.T.)
TRCell():New(oVendedor,"E3_FILIAL" ,"SE3","Filial")
TRCell():New(oVendedor,"FILNOME"   ,""   ,"","@!",30,,{|| cFilNome})

oItens := TRSection():New(oVendedor,"Comissoes",{},,,,"Totais da filial",.F.,.T.,,,,,,,.T.)

//TRCell:New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
TRCell():New(oItens,"A3_COD"    ,"SA3","Vendedor")
TRCell():New(oItens,"A3_NOME"   ,"SA3","Nome")
TRCell():New(oItens,"E3_PREFIXO","SE3","Prefixo")
TRCell():New(oItens,"E3_NUM"    ,"SE3","No. Nota")
TRCell():New(oItens,"E3_CODCLI" ,"SE3","Cliente")
TRCell():New(oItens,"A1_NREDUZ" ,"SA1","N Fantasia")
TRCell():New(oItens,"E3_EMISSAO","SE3","Dt Comissao")
TRCell():New(oItens,"F2_VALBRUT","SF2","Vlr Nota","@E 9,999,999.99",,,,,,"RIGHT")
TRCell():New(oItens,"E3_BASE"   ,"SE3","Vlr Base","@E 9,999,999.99",,,,,,"RIGHT")
TRCell():New(oItens,"E3_PORC"   ,"SE3","%","@E 999.99"      ,,,,,,"RIGHT")
TRCell():New(oItens,"E3_COMIS"  ,"SE3","Comissao","@E 99,999.99"   ,,,,,,"RIGHT")

//TRFunction():New( <oCell> , <cName> , <cFunction> , <oBreak> , <cTitle> , <cPicture> , <uFormula> , <lEndSection> , <lEndReport> , <lEndPage> , <oParent> , <bCondition> , <lDisable> , <bCanPrint> ) 
TRFunction():New(oItens:Cell("F2_VALBRUT"),NIL,"SUM",,       ,"@E 99,999,999.99",,.F.,.T.,.F.)
TRFunction():New(oItens:Cell("E3_BASE")   ,NIL,"SUM",,       ,"@E 99,999,999.99",,.F.,.T.,.F.)
TRFunction():New(oItens:Cell("E3_COMIS")  ,NIL,"SUM",,"Total","@E 99,999,999.99",,.T.,.T.,.F.)

Return (oReport)
/*---------------------------------------------------------------------------*/
Static Function PrintReport(oReport)
Local cNewAlias := GetNextAlias()
Local aFilNome := {}

//oReport:Section(1):Cell("A3_COD"):Disable()

oReport:Section(1):BeginQuery()
BeginSql Alias cNewAlias
	SELECT E3_FILIAL,A3_COD,A3_NOME,E3_PREFIXO,E3_NUM,E3_CODCLI,A1_NREDUZ,E3_EMISSAO,
	CASE WHEN E3_ORIGEM = 'D' THEN F1_VALBRUT ELSE F2_VALBRUT END F2_VALBRUT,E3_BASE,E3_PORC,E3_COMIS 
	FROM %table:SE3% SE3 INNER JOIN %table:SA3% SA3 ON 
	A3_FILIAL = E3_FILIAL AND A3_COD = E3_VEND AND SA3.%notdel% 
    INNER JOIN %table:SA1% SA1 ON 
	A1_FILIAL = %xFilial:SA1% AND A1_COD = E3_CODCLI AND A1_LOJA = E3_LOJA AND SA1.%notdel% 
    LEFT OUTER JOIN %table:SF2% SF2 ON 
	F2_FILIAL = E3_FILIAL AND F2_DOC = E3_NUM AND F2_SERIE = E3_SERIE AND E3_ORIGEM <> 'D' AND SF2.%notdel% 
    LEFT OUTER JOIN %table:SF1% SF1 ON 
	F1_FILIAL = E3_FILIAL AND F1_DOC = E3_NUM AND F1_SERIE = E3_SERIE AND F1_FORNECE = E3_CODCLI AND F1_LOJA = E3_LOJA AND E3_ORIGEM = 'D' AND SF1.%notdel% 
	WHERE E3_FILIAL BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND 
    E3_EMISSAO BETWEEN %Exp:dtos(mv_par03)% AND %Exp:dtos(mv_par04)% AND 
    E3_VEND BETWEEN %Exp:mv_par05% AND %Exp:mv_par06% AND SE3.%notdel% 
	ORDER BY E3_FILIAL,A3_COD,E3_EMISSAO,E3_PREFIXO,E3_NUM
EndSql
//	A3_FILIAL = %xFilial:SA3% AND A3_COD = E3_VEND AND SA3.%notdel% 

oReport:Section(1):EndQuery()
oReport:Section(1):Section(1):SetParentQuery()
//oReport:Section(1):Print()

oReport:SetMeter((cNewAlias)->(RecCount()))

While !oReport:Cancel() .and. (cNewAlias)->(!Eof())
    aFilNome := FwSM0Util():GetSM0Data(cEmpAnt,(cNewAlias)->E3_FILIAL,{"M0_FILIAL"})
    cFilNome := aFilNome[1,2]

	oReport:Section(1):Init()
	oReport:Section(1):PrintLine()
	oReport:Section(1):Section(1):Init()

	cFilCom := (cNewAlias)->E3_FILIAL
	While !oReport:Cancel() .and. (cNewAlias)->(!Eof() .and. E3_FILIAL = cFilCom)
		oReport:IncMeter()

		oReport:Section(1):Section(1):PrintLine()

		(cNewAlias)->(dBSkip())
	Enddo
	oReport:Section(1):Section(1):Finish()
	oReport:Section(1):Finish()

	If !oReport:Cancel() .and. (cNewAlias)->(!Eof())
		oReport:ThinLine()
	Endif
Enddo

Return Nil
/*---------------------------------------------------------------------------*/
Static Function ValParam()
Local lRet := .T.

If Empty(mv_par02)
    FWAlertError("Informe a filial final")
    lRet := .F.
ElseIf mv_par02 < mv_par01
    FWAlertError("O código da filial final deve ser maior ou igual ao código da filial inicial")
    lRet := .F.
ElseIf Empty(mv_par04)
    FWAlertError("Informe a data de emissão final")
    lRet := .F.
ElseIf mv_par04 < mv_par03
    FWAlertError("A data de emissão final deve ser maior ou igual a data de inicial inicial")
    lRet := .F.
ElseIf Empty(mv_par06)
    FWAlertError("Informe o vendedor final")
    lRet := .F.
ElseIf mv_par06 < mv_par05
    FWAlertError("O código do vendedor final deve ser maior ou igual ao código do vendedor inicial")
    lRet := .F.
EndIf

Return lRet
