//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} XREQPRRE
Relat�rio - Requis. Producao 'RE'         
@author Nunes
@since 21/06/2019
@version 1.0
	@example
	u_XREQPRRE()
	
/*/
	
User Function XREQPRRE()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Defini��es da pergunta
	cPerg := " "
	
	/*/Se a pergunta n�o existir, zera a vari�vel
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	EndIf
	
	Pergunte(cPerg,.T.) //CHAMAR PERGUNTAS AO CLICAR NO RELAT�RIO
	*/
	
	IF Perg (cPerg)
	
	//Cria as defini��es do relat�rio
	oReport := fReportDef()
	
	//Ser� enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
	//Sen�o, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf
  EndIf
  
	RestArea(aArea)
Return
	
/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Fun��o que monta a defini��o do relat�rio                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	Local oFunTot1 := Nil
	
	//Cria��o do componente de impress�o
	oReport := TReport():New(	"XREQPRRE",;		//Nome do Relat�rio
								"Requis. Producao RE",;		//T�tulo
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, ser� impresso uma p�gina com os par�metros, conforme privil�gio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de c�digo que ser� executado na confirma��o da impress�o
								)		//Descri��o
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	
	//Criando a se��o de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a se��o pertence
									"Dados",;		//Descri��o da se��o
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira ser� considerada como principal da se��o
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relat�rio
	TRCell():New(oSectDad, "D3_FILIAL", "QRY_AUX", "Filial", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_TM", "QRY_AUX", "TP Movimento", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_COD", "QRY_AUX", "Produto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_DESC", "QRY_AUX", "Descricao", /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_TIPO", "QRY_AUX", "Tipo", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_TIPOBN", "QRY_AUX", "Tipo BN", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_CONTA", "QRY_AUX", "C.contabil produto", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_UM", "QRY_AUX", "Unidade", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_QUANT", "QRY_AUX", "Quantidade", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_CF", "QRY_AUX", "Tipo RE/DE", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_LOCAL", "QRY_AUX", "Armazem", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_DOC", "QRY_AUX", "Documento", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_OP", "QRY_AUX", "Ord Producao", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_EMISSAO", "QRY_AUX", "DT Emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_SEQCALC", "QRY_AUX", "Seq.Recalc.", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "D3_CUSTO1", "QRY_AUX", "Custo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	//Definindo a quebra
	oBreak := TRBreak():New(oSectDad,{|| QRY_AUX->(B1_TIPO) },{|| "SEPARACAO DO RELATORIO" })
	oSectDad:SetHeaderBreak(.T.)
	
	//Totalizadores
	oFunTot1 := TRFunction():New(oSectDad:Cell("D3_CUSTO1"),,"SUM",oBreak,,"@E 999,999,999.99")
	oFunTot1:SetEndReport(.F.)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Fun��o que imprime o relat�rio                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as se��es do relat�rio
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT D3_FILIAL,D3_TM,D3_COD,B1_DESC,B1_TIPO,B1_TIPOBN,B1_CONTA,D3_UM,D3_QUANT,D3_CF,D3_LOCAL,D3_DOC,D3_OP,D3_EMISSAO,D3_SEQCALC,D3_CUSTO1 FROM " + retSqlName("SD3") + " SD3" 		+ STR_PULA
	cQryAux += "  INNER JOIN " + retSqlName("SB1") + " SB1 ON SD3.D3_COD = SB1.B1_COD"		+ STR_PULA
	cQryAux += "    WHERE SD3.D3_FILIAL  ='"+XFILIAL("SD3")+"'"		+ STR_PULA
	cQryAux += "      AND SD3.D3_EMISSAO>= '"+DTOS(MV_PAR01)+"'"		+ STR_PULA
	cQryAux += "      AND SD3.D3_EMISSAO<= '"+DTOS(MV_PAR02)+"'"		+ STR_PULA
	cQryAux += "      AND SD3.D3_OP      <> '             '"		+ STR_PULA
	cQryAux += "      AND SUBSTRING(D3_OP,7,2) <> 'OS'"		+ STR_PULA
	cQryAux += "      AND SD3.D3_CF      <> '             '"		+ STR_PULA
	cQryAux += "      AND SD3.D3_CF      <> 'PR0'"		+ STR_PULA
	cQryAux += "      AND SD3.D3_CF      <> 'PR1'"		+ STR_PULA
	cQryAux += "      AND SD3.D3_TM      > '500'"		+ STR_PULA
	cQryAux += "      AND SD3.D3_ESTORNO <> 'S'"		+ STR_PULA
	cQryAux += "      AND SD3.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "      AND SB1.B1_FILIAL  = '"+XFILIAL("SB1")+"'"		+ STR_PULA
	cQryAux += "      AND SB1.B1_COD     = SD3.D3_COD"		+ STR_PULA
	cQryAux += "      AND SB1.D_E_L_E_T_ = ' '"		+ STR_PULA
	cQryAux += "	  GROUP BY SB1.B1_TIPO,SB1.B1_TIPOBN,SB1.B1_CONTA,SD3.D3_FILIAL,SD3.D3_TM,SD3.D3_COD,SB1.B1_DESC,SD3.D3_UM,SD3.D3_QUANT,SD3.D3_CF,SD3.D3_LOCAL,SD3.D3_DOC,SD3.D3_OP,SD3.D3_EMISSAO,SD3.D3_SEQCALC,SD3.D3_CUSTO1 "		+ STR_PULA
	cQryAux += "	  ORDER BY SB1.B1_TIPO,SD3.D3_EMISSAO,SD3.D3_COD ASC"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da r�gua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	TCSetField("QRY_AUX", "D3_EMISSAO", "D")
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a r�gua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return


/**************************************************************************
Perguntas Relatorio
***************************************************************************/
Static Function Perg(cPerg)
Local aParBox 		:= {}
//Local aCombo	:= {"1=Metal","2=Plastico"}

aadd(aParBox,{1,"Data De",CTOD("")	,"","","","",50,.F.	})	//MV_PAR01
aadd(aParBox,{1,"Data At�",CTOD("")	,"","","","",50,.T.	})	//MV_PAR02

/*aadd(aParBox,{1,"Filial De",Space(TamSX3("Z04_FILIAL")[1])	,"","","FWSM0","",50,.F.	})	//MV_PAR01
aadd(aParBox,{1,"Filial At�",Space(TamSX3("Z04_FILIAL")[1])	,"","","FWSM0","",50,.T.	})	//MV_PAR02
aadd(aParBox,{1,"Data De",CTOD("")	,"","","","",50,.F.	})	//MV_PAR03
aadd(aParBox,{1,"Data At�",CTOD("")	,"","","","",50,.T.	})	//MV_PAR04
aadd(aParBox,{1,"Order De",Space(TamSX3("ZZ3_ORDER")[1])	,"","","","",50,.F.	})	//MV_PAR05
aadd(aParBox,{1,"Order At�",Space(TamSX3("ZZ3_ORDER")[1])	,"","","","",50,.T.	})	//MV_PAR06
aadd(aParBox,{1,"Produto De",Space(TamSX3("B1_COD")[1])	    ,"","","SB1","",50,.F.	})	//MV_PAR07
aadd(aParBox,{1,"Produto At�",Space(TamSX3("B1_COD")[1])	,"","","SB1","",50,.T.	})	//MV_PAR08
aadd(aParBox,{1,"Coleta De" ,0	,"@E 999999999","","","",50,.F.	})	//MV_PAR09
aadd(aParBox,{1,"Coleta At�",0	,"@E 999999999","","","",50,.T.	})	//MV_PAR10
AADD(aParBox,{2,"Tipo 			  	"," ",aCombo,50,"",.T.})									//MV_PAR09
*/
lRet := ParamBox(aParBox,cPerg,,,,,,,,cPerg,.T.,.T.)
	
return lRet

