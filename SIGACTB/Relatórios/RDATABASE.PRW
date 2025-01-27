#include "protheus.ch"


User Function RDATABASE()

Local oReport

Private cPergRel := "RDATABASE"

ValidPerg(cPergRel)	

If TRepInUse()	
	Pergunte(cPergRel,.T.)	
	oReport := ReportDef()
	oReport:SetParam(cPergRel)	
	oReport:PrintDialog()	
EndIf

Return

Static Function ReportDef()
Local oReport
Local oSection
Local oBreak   

oReport := TReport():New("RDATABASE","Balancete","RDATABASE",{|oReport| PrintReport(oReport)},"Balancete")

oSection := TRSection():New(oReport,"Balancete",{"SA1","SB1","SD2"})

TRCell():New(oSection,"DATAMOV",""	,"DATA",/*Picture*/					,10  ,/*lPixel*/,{||STOD(QRYEMP->DATAMOV) })
TRCell():New(oSection,"CONTA",""	,"CONTA",/*Picture*/				,10  ,/*lPixel*/,{||QRYEMP->CONTA })
TRCell():New(oSection,"DESCRICAO","","DESCRICAO",/*Picture*/			,40  ,/*lPixel*/,{||QRYEMP->DESCRICAO })
TRCell():New(oSection,"GRUPO",""	,"GRUPO",/*Picture*/				,8  ,/*lPixel*/,{||QRYEMP->GRUPO })
TRCell():New(oSection,"LOTE",""		,"LOTE",/*Picture*/					,8  ,/*lPixel*/,{||QRYEMP->LOTE })
TRCell():New(oSection,"SBLOTE",""	,"SUB LOTE",/*Picture*/				,5  ,/*lPixel*/,{||QRYEMP->SBLOTE })
TRCell():New(oSection,"DOC",""		,"DOCUMENTO",/*Picture*/    		,10  ,/*lPixel*/,{||QRYEMP->DOC })
TRCell():New(oSection,"LINHA",""	,"LINHA",/*Picture*/            	,6  ,/*lPixel*/,{||QRYEMP->LINHA })
TRCell():New(oSection,"HIST",""		,"HISTORICO",/*Picture*/        	,40  ,/*lPixel*/,{||QRYEMP->HIST })
TRCell():New(oSection,"FILIAL",""	,"FILIAL",/*Picture*/  				,5  ,/*lPixel*/,{||QRYEMP->FILIAL })
TRCell():New(oSection,"CCUSTO",""	,"C. CUSTO",/*Picture*/             ,10  ,/*lPixel*/,{||QRYEMP->CCUSTO })
TRCell():New(oSection,"VLR_DEBITO","","VLR. DEBITO",/*Picture*/         ,20  ,/*lPixel*/,{||QRYEMP->VLR_DEBITO },,,"RIGHT")
TRCell():New(oSection,"VLR_CREDITO","","VLR. CREDITO",/*Picture*/   	,20  ,/*lPixel*/,{||QRYEMP->VLR_CREDITO },,,"RIGHT")
TRCell():New(oSection,"MOVIMENTO","","MOVIMENTO",/*Picture*/      	    ,20  ,/*lPixel*/,{||QRYEMP->MOVIMENTO },,,"RIGHT")

//oBreak := TRBreak():New(oSection,oSection:Cell("A1_COD"),"Sub Total Por Cliente")
TRFunction():New(oSection:Cell("VLR_DEBITO"),Nil,"SUM",oBreak)
TRFunction():New(oSection:Cell("VLR_CREDITO"),Nil,"SUM",oBreak)
TRFunction():New(oSection:Cell("MOVIMENTO"),Nil,"SUM",oBreak)

Return oReport


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function PrintReport(oReport)

Local oSection := oReport:Section(1)
Local cPart
Local cFiltro   := ""

//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query 	
MakeSqlExpr("RDATABASE")	
oSection:BeginQuery()	

cDataDe 	:= DTOS(MV_PAR01)
cDataAt 	:= DTOS(MV_PAR02)
cFilialDe:= Alltrim(MV_PAR03)
cFilialAt:= Alltrim(MV_PAR04)

BeginSql alias "QRYEMP"		
	

	SELECT CT2_DATA DATAMOV, CT2_DEBITO CONTA, CT1_DESC01 DESCRICAO, CT1_GRUPO GRUPO, CT2_LOTE LOTE , CT2_SBLOTE SBLOTE , CT2_DOC DOC  , CT2_LINHA LINHA , CT2_HIST HIST, CT2_FILIAL FILIAL, CT2_CCD  CCUSTO,CT2_VALOR VLR_DEBITO, 0 AS VLR_CREDITO, CT2_VALOR AS MOVIMENTO
	FROM CT22H0 CT2 
	INNER JOIN CT12H0 CT1 ON CT1_CONTA = CT2_DEBITO
	WHERE CT2_DATA BETWEEN %exp:cDataDe% AND %exp:cDataAt% 
	AND CT2.%notDel%
	AND CT2_FILIAL BETWEEN %exp:cFilialDe% AND %exp:cFilialAt% 
	AND CT2_DEBITO <> '' 
	AND CT1.%notDel%
	
	UNION 
	
	SELECT CT2_DATA DATAMOV, CT2_CREDIT CONTA, CT1_DESC01 DESCRICAO , CT1_GRUPO GRUPO, CT2_LOTE LOTE, CT2_SBLOTE SBLOTE , CT2_DOC DOC  , CT2_LINHA LINHA, CT2_HIST HIST , CT2_FILIAL FILIAL , CT2_CCC CCUSTO , 0 as VLR_DEBITO, CT2_VALOR AS VLR_CREDITO, - CT2_VALOR AS MOVIMENTO
	FROM CT22H0 CT2 
	INNER JOIN CT12H0 CT1 ON CT1_CONTA = CT2_CREDIT
	WHERE CT2_DATA BETWEEN %exp:cDataDe% AND %exp:cDataAt% 
	AND CT2.%notDel%
	AND CT2_FILIAL BETWEEN %exp:cFilialDe% AND %exp:cFilialAt% 
	AND CT2_CREDIT <> '' 
	AND CT1.%notDel%
	
	ORDER BY 1 , 2
	
EndSql	

/*	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 	pela funcao MakeSqlExpr para serem adicionados a query	*/	
oSection:EndQuery()
cSqlBkp := GetLastQuery()
oSection:Print()           

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg º Autor ³ Jackson Santos     º Data ³  15/01/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definição das Perguntas.                                   º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg(cPerg)
Local aRegs := {}
Local i,j
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,len(SX1->X1_GRUPO))
	
	// Grupo/Ordem/Pergunta/Perg.Spa/Perg.Eng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/DefSpa01/DefEng01/Cnt01/Var02/Def02/DefSpa02/DefEng02/Cnt02/Var03/Def03/DefSpa03/DefEng03/Cnt03/Var04/Def04/DefSpa04/DefEng04/Cnt04/Var05/Def05/DefSpa05/DefEng05/Cnt05/F3/PYME/GRPSXG/HELP/PICTURE/IDFIL
	AADD(aRegs,{cPerg,"01","Periodo De:   ","","","mv_ch1" ,"D",08,0,0,"G","" ,"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Periodo Até:  ","","","mv_ch2" ,"D",08,0,0,"G","" ,"MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Filial De:    ","","","mv_ch3" ,"C",02,0,0,"G","" ,"MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})
	AADD(aRegs,{cPerg,"04","Filal Até:    ","","","mv_ch4" ,"C",02,0,0,"G","" ,"MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
Return

