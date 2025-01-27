#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 04/10/2019
@Hora: 16:21:44
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Enviar automaticamente e-mail 
mostrando as vendas Totvs ao final do dia. 
--------------------------------------------*/
User Function VAWKF020()

	Local cHtml		:= ""
	Local cPerg 	:= Padr("VAWKF020",10)
	Local lOk		:= .F.
	
	Private aVendas	:= {}
	
	//----------------------------------------------------------------------------------------
	//Cria as perguntas
	//----------------------------------------------------------------------------------------
	ASCRIASX1(cPerg)
	if !Pergunte(cPerg,.T.)
		Return()
	endif
	
	MsgRun("Carregando dados de vendas das lojas...", "Aguarde...",{|| CursorWait() ,lOk := VAFILDAD(), CursorArrow()})
	
	if lOk
		MsgInfo("E-mail enviado com sucesso!","Aviso")
	endif
	
Return

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 04/10/2019
@Hora: 16:50:55
@Versão: 1.0
@Uso: Valentino 
@Descrição: Processamento dos dados.
--------------------------------------------*/
Static Function VAFILDAD()

	Local lRet	:= .F.
	
	//Carrega os Dados
	LoadDados()
			
	//Cria o corpo do e-mail
	cHtml := xCorpoHtm()
						
	//Geracao do e-mail .
	lRet := GeraMail(cHtml)
	
Return(lRet)
						
/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 04/10/2019
@Hora: 16:50:55
@Versão: 1.0
@Uso: Valentino 
@Descrição: Query Genérica que retornará as vendas.

--------------------------------------------*/
Static Function LoadDados()

	Local cQuery	:= ""
	
	Local lVndCFOP	:= SuperGetMV("SY_VNDCFOP",,.F.) 					// Considera como venda os CFOPs informados no parametro SY_CODCFOP
	Local cCodCFOP	:= U_SyTrataPar(SuperGetMV("SY_CODCFOP",,"")) 		// CFOPs que deveram ser considerados como venda no Desempenho Comercial
	Local cSerVnd 	:= U_SyTrataPar(SuperGetMV("SY_CUBSERV",,"")) 		// Series de vendas
	Local cSerDev 	:= U_SyTrataPar(SuperGetMV("SY_CUVSERD",,"")) 		// Series de devolucoes
	Local cDirImp	:= "\DEBUG\"
	
	Local cNameSD1 	:= RetSqlName("SD1")
	Local cNameSD2 	:= RetSqlName("SD2")
	Local cNameSF2 	:= RetSqlName("SF2")
	Local cNameSF4 	:= RetSqlName("SF4")
	
	Local cAlias	:= GetNextAlias()
	
	cQuery := "	SELECT FILIAL_FULL,SUM(QTDVENDA) QTDVENDA,SUM(VALVENDA) VALVENDA,SUM(IMPOSTOS) IMPOSTOS,SUM(VENDLIQ) VENDLIQ FROM ("+ CRLF
	cQuery += "	SELECT "+ CRLF
	cQuery += " 	D2_FILIAL 			AS FILIAL_FULL, "+ CRLF
	cQuery += "		SUM(D2_QUANT)		AS QTDVENDA, "+ CRLF
	cQuery += "		SUM(D2_TOTAL)		AS VALVENDA, "+ CRLF
	cQuery += "		SUM(D2_VALICM + D2_VALIMP5 + D2_VALIMP6 + D2_VALCOF + D2_VALCSL + D2_VALINS + D2_VALIPI + D2_VALPIS) AS IMPOSTOS, "+ CRLF
	cQuery += "		SUM(D2_TOTAL - (D2_VALICM + D2_VALIMP5 + D2_VALIMP6 + D2_VALCOF + D2_VALCSL + D2_VALINS + D2_VALIPI + D2_VALPIS)) AS VENDLIQ "+ CRLF
	cQuery += "	FROM "+cNameSD2+" SD2 (NOLOCK) "+ CRLF
	cQuery += "	INNER JOIN "+cNameSF4+" 	SF4 (NOLOCK) 	ON SF4.F4_CODIGO = SD2.D2_TES "+ CRLF
	cQuery += "												AND SF4.F4_CODIGO >= '500' "+ CRLF
	cQuery += "		AND SF4.F4_FILIAL = '"+xFilial("SF4")+"' "+ CRLF
	If lVndCFOP
		cQuery += "	AND SF4.F4_CF IN "+ FormatIn( cCodCFOP, "|" )+" "+CRLF //('"+cCodCFOP+"') "+ CRLF
	Else
		cQuery += "	AND SF4.F4_DUPLIC = 'S' "+ CRLF
	EndIf
	cQuery += "		AND SF4.D_E_L_E_T_ <> '*' "+ CRLF
	
	cQuery += "	INNER JOIN "+cNameSF2+" SF2 (NOLOCK) "+ CRLF
	cQuery += "		ON SF2.F2_FILIAL = SD2.D2_FILIAL "+ CRLF
	cQuery += "		AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "+ CRLF
	cQuery += "		AND SF2.F2_LOJA = SD2.D2_LOJA "+ CRLF
	cQuery += "		AND SF2.F2_DOC = SD2.D2_DOC "+ CRLF
	cQuery += "		AND SF2.F2_SERIE = SD2.D2_SERIE "+ CRLF
	cQuery += "		AND SF2.D_E_L_E_T_ <> '*' "+ CRLF
	cQuery += "	WHERE "+ CRLF
	cQuery += "		SD2.D2_EMISSAO = '"+dtos(MV_PAR01)+"' "+ CRLF
	cQuery += "		AND SD2.D2_TIPO = 'N' "+ CRLF
	cQuery += "		AND SD2.D2_TES >= '500' "+ CRLF
	If !Empty(cSerVnd)
		cQuery += "	AND SD2.D2_SERIE IN "+ FormatIn( cSerVnd, "|" )+" "+CRLF //('"+cSerVnd+"') "+ CRLF
	EndIf
	cQuery += "		AND SD2.D_E_L_E_T_ <> '*' "+ CRLF
	cQuery += " GROUP BY D2_FILIAL "+ CRLF
	
	cQuery += " UNION ALL "+ CRLF
	
	cQuery += " SELECT "+ CRLF
	cQuery += " 		D1_FILIAL 					AS FILIAL_FULL, "+ CRLF
	cQuery += "		SUM(D1_QUANT * -1)				AS QTDVENDA, "+ CRLF
	cQuery += "		SUM((D1_TOTAL-D1_VALDESC) * -1)	AS VALVENDA, "+ CRLF
	cQuery += "		SUM(D1_VALICM + D1_VALIMP5 + D1_VALIMP6 + D1_VALCOF + D1_VALCSL + D1_VALINS + D1_VALIPI + D1_VALPIS) * -1 AS IMPOSTOS, "+ CRLF
	cQuery += "		SUM(D1_TOTAL - (D1_VALICM + D1_VALIMP5 + D1_VALIMP6 + D1_VALCOF + D1_VALCSL + D1_VALINS + D1_VALIPI + D1_VALPIS)) * -1 AS VENDLIQ "+ CRLF
	cQuery += "	FROM "+cNameSD1+" SD1 (NOLOCK) "+ CRLF
	cQuery += "	INNER JOIN "+cNameSF4+" SF4 (NOLOCK) "+ CRLF
	cQuery += "		ON SF4.F4_CODIGO = SD1.D1_TES "+ CRLF
	cQuery += "		AND SF4.F4_FILIAL = '"+xFilial("SF4")+"'"+ CRLF
	cQuery += "		AND SF4.F4_CODIGO < '500' "+ CRLF
	If lVndCFOP
		cQuery += "	AND SF4.F4_CF IN "+ FormatIn( cCodCFOP, "|" )+" "+CRLF //('"+cCodCFOP+"') "+ CRLF
	else
		cQuery += " 	AND SF4.F4_ESTOQUE = 'S' "+ CRLF
	endif
	cQuery += "		AND SF4.D_E_L_E_T_ <> '*' "+ CRLF
	cQuery += "	WHERE "+ CRLF
	cQuery += "			SD1.D1_EMISSAO = '"+dtos(MV_PAR01)+"' "+ CRLF
	cQuery += "			AND SD1.D1_TIPO = 'D' "+ CRLF
	cQuery += "			AND SD1.D1_TES < '500' "+ CRLF
	If !Empty(cSerDev)
		cQuery += "		AND SD1.D1_SERIE IN "+ FormatIn( cSerDev, "|" )+" "+CRLF //('"+cSerDev+"') "+ CRLF
	EndIf
	cQuery += "			AND SD1.D_E_L_E_T_ <> '*' "+ CRLF
	cQuery += " GROUP BY D1_FILIAL "+ CRLF
	
	cQuery += ") AS TAB1 "+ CRLF
	cQuery += " GROUP BY FILIAL_FULL "+ CRLF
	
	//----------------------------------------------------------------------------------------
	//Salva query em disco para debug.
	//----------------------------------------------------------------------------------------
	MakeDir(cDirImp)
	MemoWrite(cDirImp+"VAWKF020.SQL", cQuery)
	
	TCQUERY cQuery NEW ALIAS (cAlias)
	
	If TcSqlExec(cQuery) < 0
		Alert(TcSqlError())
		Return .F.		
	EndIf
	
	(cAlias)->(DbGoTop())
	While (cAlias)->(!EOF())
	
		AAdd(aVendas , {	(cAlias)->FILIAL_FULL,;
							POSICIONE("SM0",1,cEmpAnt+(cAlias)->FILIAL_FULL,"M0_FILIAL"),;
							(cAlias)->QTDVENDA	,;		
							(cAlias)->VALVENDA	,;
							(cAlias)->IMPOSTOS	,;
							(cAlias)->VENDLIQ		})
		
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return(.T.)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 04/10/2019
@Hora: 16:57:14
@Versão: 1.0
@Uso: 
@Descrição: Envia e-mail
--------------------------------------------*/
Static Function GeraMail(cHtml)

	Local cMailUser		:= GetMv("VA_ENVVLR1")
	Local cMailAdm		:= GetMv("VA_ENVVLR2")
	Local lRet			:= .F.

	lRet := U_FUN_EMAIL("","RESUMO DE VENDAS POR LOJAS "+DTOC(MV_PAR01),cHtml,cMailUser+";"+cMailAdm,"","")

Return(lRet)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 24/06/2019
@Hora: 16:30:12
@Versão: 1.0
@Uso: 
@Descrição: Cria corpo do e-mail
---------------------------------------------
Change:
--------------------------------------------*/
Static Function xCorpoHtm()

	Local cHtml 	:= ""
	
	Local nX		:= 0

	cHtml += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">
	cHtml += '<head>
	cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252" />
	cHtml += '<title>Untitled Document</title>
	cHtml += '<style type="text/css">
	cHtml += '<!--
	cHtml += '.style1 {
	cHtml += '				font-family: "Courier New", Courier, monospace;
	cHtml += '				font-size: 16px;
	cHtml += '				font-weight: bold;
	cHtml += '			}
	cHtml += '.style5 {	font-size: 12px; }
	cHtml += '.style6 {	font-family: "Courier New", Courier, monospace; font-size: 20px; font-weight: bold; color: #FF0000; }
	cHtml += '.style8 {
	cHtml += '				font-size: 12px;
	cHtml += '				font-family: "Courier New", Courier, monospace;
	cHtml += '				font-weight: bold;
	cHtml += '			}
	cHtml += '-->
	cHtml += '</style>
	cHtml += '</head>
	cHtml += '<body>
	cHtml += '<br>
	cHtml += '<table width="100%" border="1">
	cHtml += '  <tr>
	cHtml += '    <td class="style6">VALENTINO BRASIL</td>
	cHtml += '    <td class="style8">DATA: '+DTOC(MV_PAR01)+'</td>
	cHtml += '  </tr>
	cHtml += '</table>	
	cHtml += '<br>
	cHtml += '<table width="100%" border="1">
	cHtml += '  <tr>
	cHtml += '    <td class="style6"><div align="center" class="style6">RESUMO DE VENDAS POR LOJAS</div></td>
	cHtml += '  </tr>
	cHtml += '</table>
	cHtml += '<br>
	cHtml += '<table width="100%" border="1">
	cHtml += '  <tr>
	cHtml += '    <td class="style8">FILIAL</td>
	cHtml += '    <td class="style8">DESCRICAO</td>
	cHtml += '    <td class="style8">QUANTIDADE</td>
	cHtml += '    <td class="style8">VENDA BRUTA</td>
	cHtml += '    <td class="style8">IMPOSTOS</td>
	cHtml += '    <td class="style8">VENDA LIQUIDA</td>
	cHtml += '  </tr>
	For nX := 1 To Len(aVendas)
		cHtml += '  <tr>
		cHtml += '    <td class="style8">'+aVendas[nX][1]+'</td>
		cHtml += '    <td class="style8">'+aVendas[nX][2]+'</td>
		cHtml += '    <td class="style8">'+Transform(aVendas[nX][3],PesqPict('SD2','D2_QUANT'))+'</td>
		cHtml += '    <td class="style8">'+Transform(aVendas[nX][4],PesqPict('SD2','D2_TOTAL'))+'</td>
		cHtml += '    <td class="style8">'+Transform(aVendas[nX][5],PesqPict('SD2','D2_TOTAL'))+'</td>
		cHtml += '    <td class="style8">'+Transform(aVendas[nX][6],PesqPict('SD2','D2_TOTAL'))+'</td>
		cHtml += '  </tr>
	Next nX
	cHtml += '</table>	
	cHtml += '<p>&nbsp;</p>
	cHtml += '</body>
	cHtml += '</html>'
	
Return(cHtml)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 04/10/2019
@Hora: 16:30:12
@Versão: 1.0
@Uso: 
@Descrição: Cria pergunta SX1
---------------------------------------------
Change:
--------------------------------------------*/
Static Function ASCRIASX1(cPerg)

	Local aArea 	:= GetArea()
	Local aPerg 	:= {}
	Local i			:= 0

	Default cPerg	:= ""

	aAdd(aPerg, {cPerg, "01", "Data Emissão?", "MV_CHA", "D",08,0,"G","MV_PAR01","","","","",""})

	DbSelectArea("SX1")
	DbSetOrder(1)

	For i := 1 To Len(aPerg)

		If  !(SX1->( DbSeek( aPerg[i,1] + aPerg[i,2])))

			RecLock("SX1",.T.)
			Replace X1_GRUPO   	With aPerg[i,01]
			Replace X1_ORDEM   	With aPerg[i,02]
			Replace X1_PERGUNT 	With aPerg[i,03]
			Replace X1_VARIAVL 	With aPerg[i,04]
			Replace X1_TIPO	   	With aPerg[i,05]
			Replace X1_TAMANHO	With aPerg[i,06]
			Replace X1_PRESEL  	With aPerg[i,07]
			Replace X1_GSC	   		With aPerg[i,08]
			Replace X1_VAR01   	With aPerg[i,09]
			Replace X1_F3	  	 	With aPerg[i,10]
			Replace X1_DEF01   	With aPerg[i,11]
			Replace X1_DEF02   	With aPerg[i,12]
			Replace X1_DEF03   	With aPerg[i,13]
			Replace X1_DEF04   	With aPerg[i,14]
			SX1->( MsUnlock() )

		EndIf

	Next i

	RestArea( aArea )

Return()
