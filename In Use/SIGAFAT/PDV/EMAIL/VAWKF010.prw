#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 24/06/2019
@Hora: 16:21:44
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Enviar automaticamente e-mail 
mostrando as vendas Totvs ao final do dia. 
--------------------------------------------*/
User Function VAWKF010(cEmpTrab,cFilTrab)

	Local cHoraIni		:= ""
	Local cHoraFim		:= ""
	Local dDiaExc		:= ""
	Local cHtml		:= ""
	
	Private lVndCFOP	:= .F.
	Private cCodCFOP 	:= ""
	Private cSerVnd	:= ""
	Private cSerDev	:= ""
	Private cDirImp	:= ""
	Private cAlias		:= ""
	
	Private cNameSD1 	:= ""
	Private cNameSD2 	:= ""
	Private cNameSF1 	:= ""
	Private cNameSF2 	:= ""
	Private cNameSF4 	:= ""
	
	Private aVendas		:= {}
			
	RpcSetType(3)
	RpcSetEnv(cEmpTrab,cFilTrab)
		
	cHoraIni	:=	U_MyNewSX6("VA_HFWI010","05","C","Hora inicial do próximo envio do e-mail.",,,.F. )
	cHoraFim	:=	U_MyNewSX6("VA_HFWF010","22","C","Hora final do próximo envio do e-mail",,,.F. )	
	dDiaExc		:=	U_MyNewSX6("VA_DTWF010","25/06/2019","D","Data do próximo envio do e-mail",,,.F. )
	
	lVndCFOP	:= SuperGetMV("SY_VNDCFOP",,.F.) 					// Considera como venda os CFOPs informados no parametro SY_CODCFOP
	cCodCFOP	:= U_SyTrataPar(SuperGetMV("SY_CODCFOP",,"")) 		// CFOPs que deveram ser considerados como venda no Desempenho Comercial
	cSerVnd 	:= U_SyTrataPar(SuperGetMV("SY_CUBSERV",,"")) 		// Series de vendas
	cSerDev 	:= U_SyTrataPar(SuperGetMV("SY_CUVSERD",,"")) 		// Series de devolucoes
	cDirImp		:= "\DEBUG\"
	cAlias		:= ""
	
	cNameSD1 	:= RetSqlName("SD1")
	cNameSD2 	:= RetSqlName("SD2")
	cNameSF1 	:= RetSqlName("SF1")
	cNameSF2 	:= RetSqlName("SF2")
	cNameSF4 	:= RetSqlName("SF4")
			
	if ((Alltrim(Left(Time(),2)) >= cHoraIni) .AND. (Alltrim(Left(Time(),2)) <= cHoraFim))
		If dDiaExc == MsDate()

			CONOUT("")
			CONOUT(Replicate('-',80))
			CONOUT("INICIADO ROTINA DE ENVIO DE E-MAIL COM RESUMO DAS VENDAS: VAWKF010() - DATA/HORA: "+DToC(Date())+" AS "+Time())
			
			//Carrega os Dados
			CONOUT("CARREGANDO DADOS DAS VENDAS: VAWKF010() - DATA/HORA: "+DToC(Date())+" AS "+Time())
			LoadDados()
			
			//Cria o corpo do e-mail
			CONOUT("MONTANDO O CORPO DO E-MAIL DAS VENDAS: VAWKF010() - DATA/HORA: "+DToC(Date())+" AS "+Time())
			cHtml := xCorpoHtm()
						
			//Geracao do e-mail .
			CONOUT("GERANDO E-MAIL DAS VENDAS: VAWKF010() - DATA/HORA: "+DToC(Date())+" AS "+Time())
			GeraMail(cHtml)
			
			//Atualiza o parametro 
			PutMv("VA_DTWF010",dDataBase+1)
	
			CONOUT("FINALIZADO ROTINA DE ENVIO DE E-MAIL COM RESUMO DAS VENDAS: VAWKF010() - DATA/HORA: "+DToC(Date())+" AS "+Time())
			CONOUT(Replicate('-',80))
			CONOUT("")
			
		EndIf
	EndIf
	RpcClearEnv()
Return

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 24/06/2019
@Hora: 16:50:55
@Versão: 1.0
@Uso: Valentino 
@Descrição: Query Genérica que retornará as vendas.

--------------------------------------------*/
Static Function LoadDados()

Local cQuery	:= ""

cAlias 	:= GetNextAlias()																																																																

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
cQuery += "		SD2.D2_EMISSAO BETWEEN '"+dtos(date())+"' AND '"+dtos(date())+"' AND "+ CRLF
cQuery += "		SD2.D2_TIPO = 'N' "+ CRLF
cQuery += "		AND SD2.D2_TES >= '500' "+ CRLF
If !Empty(cSerVnd)
	cQuery += "	AND SD2.D2_SERIE IN "+ FormatIn( cSerVnd, "|" )+" "+CRLF //('"+cSerVnd+"') "+ CRLF
EndIf
cQuery += "		AND SD2.D_E_L_E_T_ <> '*' "+ CRLF
cQuery += " GROUP BY D2_FILIAL "+ CRLF

cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT "+ CRLF
cQuery += " 		D1_FILIAL 							AS FILIAL_FULL, "+ CRLF
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
cQuery += "			SD1.D1_EMISSAO BETWEEN '"+dtos(date())+"' AND '"+dtos(date())+"' AND "+ CRLF
cQuery += "			SD1.D1_TIPO = 'D' "+ CRLF
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
MemoWrite(cDirImp+"QRYGEN.SQL", cQuery)

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
@Data: 25/06/2019
@Hora: 16:57:14
@Versão: 1.0
@Uso: 
@Descrição: 
--------------------------------------------*/
Static Function GeraMail(cHtml)

	Local cMailUser		:= GetMv("VA_ENVVLR1")
	Local cMailAdm		:= GetMv("VA_ENVVLR2")

	U_FUN_EMAIL("","RESUMO DE VENDAS POR LOJAS "+DTOC(Date()),cHtml,cMailUser+";"+cMailAdm,"","")

Return

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 24/06/2019
@Hora: 16:30:12
@Versão: 1.0
@Uso: 
@Descrição: 
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
	cHtml += '    <td class="style8">DATA: '+DTOC(Date())+'</td>
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