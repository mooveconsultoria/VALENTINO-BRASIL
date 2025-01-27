#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#Include "topconn.CH"
#include "tbiconn.ch"

#DEFINE CMD_OPENWORKBOOK		1
#DEFINE CMD_CLOSEWORKBOOK		2
#DEFINE CMD_ACTIVEWORKSHEET		3
#DEFINE CMD_READCELL			4
#DEFINE POS_PRODUTO				3
#DEFINE NFASES					2

/*/{Protheus.doc} User Function CSCOM002
	³Importação de planilha excel XLSX
	@type  Function
	@author Fernando Lavor
	@since 10/23/14
	@history Muriel Zounar (28/08/2024) - Alterado ProtheusDoc para seguir novo padrão.
	@history Muriel Zounar (28/08/2024) - Criada chamada à função VACOM001.
	/*/
User Function CSCOM002()
	Private lEnd		:= .F.
	Private oProcess	:= MsNewProcess():New({|lEnd|	Process()}, "Carregando dados","Carregando...", .T.)
	PRIVATE cForLoj	:= ""
	Private _cFor	:= ""
	Private _cLoj	:= ""

	While !lEnd
		oProcess:Activate()
	EndDo
Return

/*
±±ºPrograma  ³Process   ºAutor  ³Fernando Lavor      º Data ³  10/23/14   º±±
±±ºDesc.     ³                                                            º±±
±±ºUso       ³ AP                                                         º±±
*/
Static Function Process()
	Local lContinua	:= .F.
	Local aAreaAtu	:= GetArea()
	Local aDesc		:= {}
	Local aButtons	:= {}
	Local aRetPerg	:= {}
	Local aRetExcel	:= {}
	Local aLogErros := {}

	aRetPerg := RGenrPerg()

	If Len(aRetPerg) > 0
		//cForLoj	:= xFilial("SA2") + aRetPerg[5] + aRetPerg[6]
		_cFor := aRetPerg[5]
		_cLoj := aRetPerg[6]
		aAdd(aDesc, "Este programa tem a função de gerar um pré documento de entrada ")
		aAdd(aDesc, "com base numa planilha Excel.")
		aAdd(aDesc, "IMPORTANTE: Para que a importação da planilha seja processada com sucesso, o nome da")
		aAdd(aDesc, "aba (guia) da planilha NÃO PODE CONTER ESPAÇOS. Se necessário, verifique e altere o nome")
		aAdd(aDesc, "da aba antes de iniciar o procedimento.")

		aAdd(aButtons, {5, .T., {|| aRetPerg := RGenrPerg() }})
		aAdd(aButtons, {1, .T., {|| If(	Len(aRetPerg) == 0,;
			Aviso(	"Parâmetros necessários","Para prosseguir, preencha os parâmetros", {"&Voltar"},,"Atenção",,"MSGHIGH"),;
			Eval({|| FechaBatch(), lContinua := .T.})  ) }})
		aAdd(aButtons, {2, .T., {|| FechaBatch() }})

		FormBatch("Atualizando dados...", aDesc, aButtons)

		If Len(aRetPerg) > 0 .AND. lContinua
			aRetExcel := AbreExcel(	aRetPerg[1],;
				AllTrim(aRetPerg[2]),;
				"A" + Alltrim(Str(aRetPerg[3])),;
				"AD" + Alltrim(Str(aRetPerg[4])) )
			//   "Z" + Alltrim(Str(aRetPerg[4])) ) //LINHA COMENTADA 27/11/2015 PARA INCLUIR O GRUPO TRIBUTARIO NA PLANILHA

			//³ Se existir retorno de dados da planilha executa funcao para gravar tabela³
			If Len(aRetExcel) > 0
				//³ Funcao para remover espacos em branco que foram retornados da planilha.  ³

				oProcess:SetRegua1(NFASES)
				oProcess:IncRegua1("Tratando dados da planilha...")
				aRetExcel := RemovEsp(aRetExcel, oProcess)
				oProcess:IncRegua1("Eetuando atualização de Produtos...")
				oProcess:SetRegua2(Len(aRetExcel))
				AtuContrat(aRetExcel, oProcess, aLogErros)
			EndIf
		EndIf
	EndIf

	lEnd := .T.

	RestArea(aAreaAtu)
Return()

/*
±±ºPrograma  ³AtuContratºAutor  ³Fernando Lavor      º Data ³  10/23/14   º±±
±±ºDesc.     ³ Atualiza o contrato                                        º±±
±±ºUso       ³ AP Comerc                                                  º±±
*/
Static Function AtuContrat(aRetExcel,oProcess,aLogErros)
	Local aArea		:= GetArea()
	Local aEstrut   := aRetExcel[1]
	Local aDescrComp := {}
	Local cLinha    := ""
	Local cColecao  := ""
	Local nCont     := 0

	For nCont := 1 To Len(aRetExcel)

		// Ignora a primeira linha linha
		If nCont <= 1
			Loop
		EndIf

		// Apartir da coluna Y ate a coluna AC
		// Depois a partir da coluna AF ate o final
		// Variaveis para encontrar o documento
		cCod	:= 	FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"Código de Barras")]))
		cDescr	:= 	FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"Descrição Resumida")]))
		cDesComp:= 	FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"Descrição Completa")]))
		nQuant	:= 	Val(Replace(aRetExcel[nCont][aScan(aEstrut,"Quantidade")],",","."))
		nVlUnit	:= 	Val(Replace(aRetExcel[nCont][aScan(aEstrut,"Valor Unitário = (CIF Total em R$ / Quantidade )")],",","."))

		cTipo	:= 'ME'//FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"B1_TIPO")]))
		cUM		:= FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"Unidade medida")])) // Alterado conforme solicitação Wesley Valentino 09/04/2015
		cGrupTr	:= FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"Grupo Tributario")])) // Alterado conforme solicitação Wesley Valentino 27/11/2015
		cPosIpi	:= Replace(FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"NCM")])),".","")
		If Val(Replace(aRetExcel[nCont][aScan(aEstrut,"Aliquota IPI")],",",".")) < 1
			nIpi	:= Val(Replace(aRetExcel[nCont][aScan(aEstrut,"Aliquota IPI")],",",".")) * 100
		else
			nIpi	:= Val(Replace(aRetExcel[nCont][aScan(aEstrut,"Aliquota IPI")],",","."))
		Endif
		cPicm	:= SubStr(aRetExcel[nCont][aScan(aEstrut,"Aliquota ICMS")],3,2)

		// Identificar a referencia, cor e tamanho na descricao completa - 07/11/2022 Oscar Lira TOTVS IP
		aDescrComp := STRTOKARR( Left(cDesComp,At("|",cDesComp)), " " )
		cLinha   := FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"Itens")]))
		cColecao := FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"Coleção")]))
		cTS      := FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"TSPADRAO")]))

		//============================================================================================
		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek(xFilial("SB1")+cCod+Space(TamSx3("B1_COD")[1]-Len(cCod)))
			RecLock("SB1",.F.)
		Else
			RecLock("SB1",.T.)
		EndIf
		SB1->B1_FILIAL	:= 	xFilial("SB1")
		SB1->B1_COD		:= 	cCod
		SB1->B1_DESC	:=  StrTran( cDescr, "|", " ") // Ajustado Patrick Araujo - 26/06/2018 - Substituir pipe por espaço.
		SB1->B1_TIPO	:=	cTipo
		SB1->B1_UM  	:= 	cUM
		SB1->B1_PICM	:= 	0	// Alterado conforme solicitação Wesley Valentino 09/04/2015
		SB1->B1_IPI 	:= 	nIpi
		SB1->B1_POSIPI	:= 	cPosIpi
		SB1->B1_LOCPAD 	:= 	'01'
		SB1->B1_MSBLQL 	:= 	'2'
		SB1->B1_CONTA	:= 	'113020101' // Conta
		SB1->B1_CTAREC	:= 	'311010201' // Conta
		SB1->B1_APROPRI := 	'D'
		SB1->B1_TIPODEC := 	'N'
		SB1->B1_ORIGEM	:= 	'1'
		SB1->B1_UREV	:= dDataBase
		SB1->B1_DATREF	:= dDataBase
		SB1->B1_GRTRIB  := cGrupTr
		SB1->B1_RASTRO	:= 'N'
		SB1->B1_MRP		:= 'S'
		SB1->B1_IRRF	:= 'N'
		SB1->B1_LOCALIZ := 'N'
		SB1->B1_CONTRAT	:= 'N'
		SB1->B1_ANUENTE	:= '2'
		SB1->B1_IMPORT	:= 'N'
		SB1->B1_TIPOCQ	:= 'M'
		SB1->B1_SOLICIT	:= 'N'
		SB1->B1_AGREGCU	:= '2'
		SB1->B1_DESPIMP	:= 'N'
		SB1->B1_INSS	:= 'N'
		SB1->B1_FLAGSUG	:= '1'
		SB1->B1_CLASSVE	:= '1'
		SB1->B1_MIDIA	:= '2'
		//SB1->B1_QTDSER 	:=  1
		SB1->B1_ATIVO	:= 	'S'
		SB1->B1_CPOTENC	:=	'2'
		SB1->B1_USAFEFO	:= 	'1'
		SB1->B1_RETOPER	:= 	'2'
		SB1->B1_PIS		:= 	'2'
		SB1->B1_COFINS	:= 	'2'
		SB1->B1_CSLL	:=	'2'
		SB1->B1_FETHAB	:= 	'N'
		SB1->B1_PRN944I	:= 	'S'
		SB1->B1_ESCRIPI	:= 	'3'
		SB1->B1_RICM65	:= 	'2'
		SB1->B1_REGESIM	:=	'1'
		SB1->B1_PRODSBP	:=	'P'
		SB1->B1_CARGAE	:=	'2'
		SB1->B1_GARANT	:=	'2'
		SB1->B1_CODBAR 	:=	cCod
		SB1->B1_FECP 	:=	2
		SB1->B1_ZZREFER := aDescrComp[1]
		SB1->B1_ZZLINE  := cLinha
		SB1->B1_ZZTAMAN := aDescrComp[3]
		SB1->B1_ZZCOR   := aDescrComp[2]
		SB1->B1_ZZCOLEC := cColecao
		SB1->B1_TS      := cTS
		MsUnlock()

		DbSelectArea("SB5")
		DbSetOrder(1)
		If DbSeek(xFilial("SB5")+cCod+Space(TamSx3("B5_COD")[1]-Len(cCod)))
			RecLock("SB5",.F.)
		Else
			RecLock("SB5",.T.)
		EndIf
		SB5->B5_FILIAL 	:=	xFilial("SB5")
		SB5->B5_COD    	:=	cCod
		SB5->B5_CEME	:=	Alltrim(cDesComp)
		// Tratamento para descrição do produto
		SB5->B5_DESCNFE	:=	MemoLine(cDesComp,250,1)
		MsUnLock()

		if ExistBlock('VACOM001')
			Begin Transaction
				ExecBlock('VACOM001', .F., .F., {cCod, cDescr})
			End Transaction
		endif
	Next

	fExecPSD1(aRetExcel)
	RestArea(aArea)
Return(Nil)

/*
±±ºPrograma  ³AbreExcel ºAutor  ³Fernando Lavor      º Data ³  10/23/14   º±±
±±ºDesc.     ³                                                            º±±
±±ºUso       ³ AP                                                         º±±
*/
Static Function AbreExcel(cArqPlan,cPlan,cCelIni,cCelFim)
	Local cDigCol1		:= ""
	Local cDigCol2		:= ""
	Local cBuffer		:= ""
	Local cCell 		:= ""
	Local cFile			:= ""
	Local nLin			:= 0
	Local nCol			:= 0
	Local nLinIni		:= 0
	Local nLinFim		:= 0
	Local nColIni		:= 0
	Local nColFim		:= 0
	Local nMaxLin		:= 0
	Local nMaxCol		:= 0
	Local nHdl 			:= 0
	Local nPosIni		:= 0
	Local nX			:= 0
	Local nColArr		:= 0
	Local lRet			:= .T.
	Local aReturn		:= {}
	Local aNumbers		:= {"0","1","2","3","4","5","6","7","8","9"}
	Local aErros		:= {}

	Default cArqPlan	:= ""
	Default cPlan		:= ""
	Default cCelIni		:= ""
	Default cCelFim		:= ""

	//³ Valida os parametros informados pelo usuario        		     	    ³
	If Empty(cArqPlan)
		aAdd(aErros,	{"Inconsistência - Não foi informado o diretório e a planilha a ser processada.",;
			"Informe o diretório e o nome da planilha a ser processada." })
		lRet := .F.
	Endif

	If Empty(cPlan)
		aAdd(aErros,	{"Inconsistência - Não foi informado o nome da pasta (Folder).",;
			"Informe nome do Folder da planilha a ser processada." })
		lRet := .F.
	Endif

	If Empty(cCelIni)
		aAdd(aErros,	{"Inconsistência - Não foi informado qual será a célula inicial.",;
			"Informe a referência da célula inicial a ser processada." })
		lRet := .F.
	Endif

	If Empty(cCelFim)
		aAdd(aErros,	{"Inconsistência - Não foi informado qual será a célula final.",;
			"Informe a referência da célula final a ser processada." })
		lRet := .F.
	Endif


	If lRet
		If !File(cArqPlan)
			aAdd(aErros,	{"Inconsistência - Não foi possível localizar a planilha "+Alltrim(cArqPlan)+" especificada."})
			lRet := .F.
		Else
			cFile := Alltrim(cArqPlan)
		Endif

		If lRet
			lRet := CpDllXls()

			//³ Processa a coordenada inicial da celula             		     	    ³
			nPosIni	:= 0

			For nX := 1 to Len(Alltrim(cCelIni))
				If aScan(aNumbers, Substr(cCelIni,nX,1)) > 0
					nPosIni	:= nX
					Exit
				Endif
			Next nX

			If nPosIni == 0
				aAdd(aErros,	{"Inconsistência - Não foi possivel determinar a referência numérica da linha inicial a ser processada.",;
					"Verifique a referência da célula inicial informada." })
				lRet := .F.
			Endif

			If lRet
				nLinIni := Val(Substr(cCelIni,nPosIni,(Len(cCelIni)-nPosIni)+1))

				cDigCol1 := Alltrim(Substr(cCelIni,1,nPosIni-1))

				If Len(cDigCol1) == 2
					cDigCol1 	:= Substr(cCelIni,1,1)
					cDigCol2 	:= Substr(cCelIni,2,1)
					nColIni		:= ((Asc(cDigCol1)-64)*26) + (Asc(cDigCol2)-64)
				Else
					cDigCol1 	:= Substr(cCelIni,1,1)
					cDigCol2 	:= ""
					nColIni		:= Asc(cDigCol1)-64
				Endif

				//³ Processa a coordenada final   da celula             		     	    ³
				nPosIni	:= 0
				For nX := 1 to Len(Alltrim(cCelFim))
					If aScan(aNumbers, Substr(cCelFim,nX,1)) > 0
						nPosIni	:= nX
						Exit
					Endif
				Next nX

				If nPosIni == 0
					aAdd(aErros,	{"Inconsistência - Não foi possivel determinar a referência numérica da linha final a ser processada.",;
						"Verifique a referência da célula final informada." })
					lRet := .F.
				Endif

				If lRet
					nLinFim := Val(Substr(cCelFim,nPosIni,(Len(cCelFim)-nPosIni)+1))

					cDigCol1 := Alltrim(Substr(cCelFim,1,nPosIni-1))

					If Len(cDigCol1) == 2
						cDigCol1 	:= Substr(cCelFim,1,1)
						cDigCol2 	:= Substr(cCelFim,2,1)
						nColFim		:= ((Asc(cDigCol1)-64)*26) + (Asc(cDigCol2)-64)
					Else
						cDigCol1 	:= Substr(cCelFim,1,1)
						cDigCol2 	:= ""
						nColFim		:= Asc(cDigCol1)-64
					Endif

					//³ Determina o total de linhas e colunas               		     	    ³
					nMaxLin := nLinFim - nLinIni + 1
					nMaxCol := nColFim - nColIni + 1

					//³ Abre a DLL de interface excel                                            ³
					nHdl := ExecInDLLOpen(Alltrim(GetMv("OK_DRDLLXLS",,"c:\TEMP"))+'\readexcel.dll')

					If nHdl < 0
						aAdd(aErros,	{"Inconsistência - Não foi possível carregar a DLL de interface com o Excel (readexcel.dll).",;
							"Contate o administrador do sistema." })
						lRet := .F.
					Endif
					If lRet
						//³ Carrega o excel e abre o arquivo                                         ³
						cBuffer := cFile+Space(512)
						nBytes  := ExeDLLRun2(nHdl, CMD_OPENWORKBOOK, @cBuffer)

						//³ Valida se abriu a planilha corretamente                                  ³
						If nBytes < 0
							aAdd(aErros,	{"Inconsistência - Não foi possível abrir a planilha Excel solicitada ("+Alltrim(cFile)+").",;
								"Contate o administrador do sistema." })
							lRet := .F.
						ElseIf nBytes > 0
							aAdd(aErros,	{"Inconsistência - Não foi possível abrir a planilha Excel solicitada ("+Alltrim(cFile)+").",;
								"Erro interno: "+Subs(cBuffer, 1, nBytes),;
								"Contate o administrador do sistema." })
							lRet := .F.
						EndIf

						If lRet
							//³ Seleciona a worksheet                                  					 ³
							cBuffer := Alltrim(cPlan)+Space(512)
							nBytes 	:= ExeDLLRun2(nHdl,CMD_ACTIVEWORKSHEET,@cBuffer)

							//³ Valida se selecionou o worksheet solicitado                              ³
							If nBytes < 0
								aAdd(aErros,	{"Inconsistência - Não foi possível selecionar a WorkSheet solicitada ("+Alltrim(cPlan)+;
									") na planilha Excel ("+Alltrim(cFile)+")." })
								cBuffer := Space(512)
								ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
								ExecInDLLClose(nHdl)
								lRet := .F.
							ElseIf nBytes > 0
								aAdd(aErros,	{"Inconsistência - Não foi possível selecionar a WorkSheet solicitada ("+Alltrim(cPlan) +;
									") na planilha Excel ("+Alltrim(cFile)+").",;
									"Erro interno: " + Subs(cBuffer, 1, nBytes) })

								cBuffer := Space(512)
								ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
								ExecInDLLClose(nHdl)
								lRet := .F.
							EndIf

							If lRet
								//³ Define a regua de processamento                                          ³
								//ProcRegua(nMaxLin*nMaxCol)
								oProcess:SetRegua1(nMaxLin)
								oProcess:SetRegua2(nMaxLin*nMaxCol)

								//³ Gera o array com todas as coordenadas necessarias   		     	    ³
								For nLin := nLinIni to nLinFim
									//³ Adiciona no array a linja a ser importada                                ³
									Aadd(aReturn, Array(nMaxCol))

									oProcess:IncRegua1("Importando planilha...")
									//³ Processa as colunas da linha atual                                       ³
									nColArr := 0
									For nCol := nColIni to nColFim
										nColArr++
										If Int((nCol/26)-0.01) > 0
											cDigCol1 := Chr(Int((nCol/26)-0.01)+64)
										Else
											cDigCol1 := " "
										Endif
										If nCol - (Int((nCol/26)-0.01)*26) > 0
											cDigCol2 := Chr((nCol - (Int((nCol/26)-0.01)*26))+64)
										Else
											cDigCol2 := " "
										Endif
										//³ Incrementa a regua de processamento                                      ³
										oProcess:IncRegua2("Importando Células...")

										//³ Compoe a coordenada da celula a ser importada                            ³
										cCell := Alltrim(cDigCol1)+Alltrim(cDigCol2)+Alltrim(Str(nLin))

										//³ Realiza a leitura da celula no excel                                     ³
										cBuffer := cCell+Space(1024)
										nBytes 	:= ExeDLLRun2(nHdl, CMD_READCELL, @cBuffer)
										aReturn[Len(aReturn),nColArr] := Subs(cBuffer, 1, nBytes)
									Next nCol
								Next nLin

								//³ Fecha a interface com o excel                                            ³
								cBuffer := Space(512)
								ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
								ExecInDLLClose(nHdl)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return(aReturn)

/*
±±ºPrograma  ³NOVO5     ºAutor  ³Fernando Lavor      º Data ³  10/23/14   º±±
±±ºDesc.     ³                                                            º±±
±±ºUso       ³ AP                                                        º±±
*/
Static Function RemovEsp(aArray, oRegua)
	Local nPosProd	:= 1
	Local nCount	:= 0
	Local nLenOri	:={}
	Local aAreaAtu	:= GetArea()
	Default aArray	:= {}
	Default oRegua	:= Nil

	If Len(aArray) > 0

		If ValType(oRegua) == "O"
			oRegua:SetRegua2(Len(aArray))
		EndIf

		nLenOri := Len(aArray)

		While nPosProd > 0 .AND. nCount <= nLenOri
			nCount++

			If ValType(oRegua) == "O"
				oRegua:IncRegua2("Removendo linhas vazias...")
			EndIf

			nPosProd := aScan(aArray, {|x| Empty(x[1]) })
			If nPosProd > 0
				aDel(aArray, nPosProd)
				aSize(aArray, Len(aArray) - 1)
			EndIf
		EndDo
	EndIf

	RestArea(aAreaAtu)
Return(aArray)

/*
±±ºPrograma  ³CpDllXls  ºAutor  ³Fernando Lavor      º Data ³  10/23/14   º±±
±±ºDesc.     ³                                                            º±±
±±ºUso       ³ AP Comerc                                                  º±±
*/
Static Function CpDllXls()
	Local cDirDest	:= Alltrim(GetMv("CO_DRDLLXLS",,"c:\TEMP"))
	Local nResult	:= 0
	Local lReturn	:= .T.

	//³Cria o diretorio de destino da DLL na estacao do usuario                       ³
	If !lIsDir(cDirDest)
		nResult := MakeDir(cDirDest)
	Endif
	If nResult <> 0
		Aviso("Inconistência","Não foi possível criar o diretório "+cDirDest+" para a DLL de leitura da planilha Excel.",{"Sair"},,"Atenção:")
		lReturn := .F.
	Else
		//³Copia a DLL para o diretorio na estacao do usuario                             ³
		If !File("ReadExcel.dll")
			Aviso(	"Inconistência","Não foi possível localizar a DLL de leitura da planilha excel (ReadExcel.dll) no diretório SYSTEM ou SIGAADV.",;
				{"Sair"},,"Atenção:")
			lReturn := .F.
		Else
			If !File(cDirDest+"\ReadExcel.dll")
				COPY FILE ("ReadExcel.dll") TO (cDirDest+"\ReadExcel.dll")
				If !File(cDirDest+"\ReadExcel.dll")
					Aviso("Inconistência","Não foi possível copiar a DLL de leitura da planilha excel para o diretório "+cDirDest+".",{"Sair"},,"Atenção:")
					lReturn := .F.
				Endif
			Endif
		Endif
	Endif
Return(lReturn)

/*
±±ºPrograma  ³RGENPERG  ºAutor  ³Fernando Lavor      º Data ³  10/23/14   º±±
±±ºDesc.     ³                                                            º±±
±±ºUso       ³ AP                                                         º±±
*/
Static Function RGenrPerg()
	Local cTitulo	:= "Parâmetros para importar arquivo"
	Local aParambox	:= {}								//Array com os tipos de Parambox
	Local aRet		:= {}				 				//Array com o retorno do pergunte
	Local aAreaAtu	:= GetArea()

	aAdd(aParamBox,{6, "Selecionar Arquivo.: ", Space(230), "", "", "", 80, .T., "Arquivos XLS|*.XLS|Todos os Arquivos|*.*", "\SERVIDOR", GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE})
	aAdd(aParamBox,{1, "Nome Folder da Planilha", Space(30), "@!", "",	"",	"",	80,	.T.})
	aAdd(aParamBox,{1, "Linha Inicial da Planilha",	1, "@E 99999", "NaoVazio() .AND. Entre(1,1)", "", "", 5, .T.})
	aAdd(aParamBox,{1, "Linha Final da Planilha", 2, "@E 99999", "NaoVazio() .AND. Entre(2,900) ", "", "", 5, .T.})
	aAdd(aParamBox,{1,"Fornecedor",Space(TAMSX3("A2_COD")[1]),"","NaoVazio()","SA2","",0,.T.}) // Tipo caractere
	aAdd(aParamBox,{1,"Loja",Space(TAMSX3("A2_LOJA")[1]),"","NaoVazio() .AND. SA2->(DbSeek(xFilial('SA2')+MV_PAR05+MV_PAR06))","","",0,.T.}) // Tipo caractere
	ParamBox(aParamBox, cTitulo, @aRet,,,,,,,, .T., .T.)

	RestArea(aAreaAtu)
Return(aRet)

/*
±±ºPrograma  ³NOVO2     ºAutor  ³Fernando Lavor      º Data ³  02/01/15   º±±
±±ºDesc.     ³ Ms ExecAuto Pré nota de entrada.                           º±±
±±ºUso       ³ AP Controle                                                º±±
*/
Static Function fExecPSD1(aRetExcel)
	//³Declaracao de variavei.     ³
	Local aArea		:= GetArea()
	Local aEstrut   := aRetExcel[1]
	Local nOpc 		:= 0
	Local lRetorno	:= .F.
	Local cSerie	:= GetMv("VA_XSRIMP",,"2")
	Local cTipoNF	:= 'N'
	//Local cTipoNF	:= SuperGetMV("MV_TPNRNFS")
	Local aLinha	:= {}
	Local aCabec	:= {}
	Local aItens	:= {}
	Local aProdEr	:= {}
	//Local cForLoj	:= GetMv("VA_XFORIMP",,"00030601")
	Local nCont		:= 0
	Private cNumero := ""
	Private lMsErroAuto := .F.

	//³Numero da NF.										                           ³
	lRetorno := Sx5NumNota(@cSerie,cTipoNF)

	//³Caso tenha escolhido alguma numeração segue o processamento.                    ³
	If lRetorno
		//³Ajusta e procura itens informados na planilha.							       ³
		cNumDI	:= 	FwNoAccent(Alltrim(aRetExcel[2][aScan(aEstrut,"Número da DI")]))
		cNumDI  :=  StrTran( cNumDI, "/", "") // Ajustado Patrick Araujo - 26/06/2018 - Remover barra da DI.
		cNumDI  :=  StrTran( cNumDI, "-", "") // Ajustado Patrick Araujo - 26/06/2018 - Remover traco da DI.
		dDataDI	:=  cTod(FwNoAccent(Alltrim(aRetExcel[2][aScan(aEstrut,"Data da DI")])))
		dDataDs	:=	cTod(FwNoAccent(Alltrim(aRetExcel[2][aScan(aEstrut,"Data do Desembaraço")])))
		cLocDs	:=	FwNoAccent(Alltrim(aRetExcel[2][aScan(aEstrut,"Local Desembaraço")]))
		cInfCom	:=	FwNoAccent(Alltrim(aRetExcel[2][aScan(aEstrut,"Informações Complementares")]))

		//³Escreve o cabeçalho da NF.												       ³
		/*aCabec := 	{	{'F1_TIPO'	,cTipoNF		,NIL},;
		{'F1_FORMUL'	,'S'  						,NIL},;
		{'F1_DOC'		,cNumero  					,NIL},;
		{'F1_SERIE' 	,cSerie	 					,NIL},;
		{'F1_EMISSAO'	,dDataBase					,NIL},;
		{'F1_FORNECE'	,SubStr(cForLoj,1,6)		,NIL},;
		{'F1_LOJA'		,SubStr(cForLoj,7,2) 		,NIL},;
		{'F1_ESPECIE'	,'SPED'					,NIL},;
		{'F1_XDOCIMP'	,cNumDI					,NIL},;
		{'F1_XNDI   '	,cNumDI					,NIL},;
		{'F1_XDTDI  '	,dDataDI				,NIL},;
		{'F1_XLOCDES'	,cLocDs					,NIL},;
		{'F1_XDTDES '	,dDataDs				,NIL},;
		{'F1_XINFOIM'	,cInfCom				,NIL}}*/
		
		aCabec := 	{	{'F1_TIPO'	,cTipoNF		,NIL},;
		{'F1_FORMUL'	,'S'  						,NIL},;
		{'F1_DOC'		,cNumero  					,NIL},;
		{'F1_SERIE' 	,cSerie	 					,NIL},;
		{'F1_EMISSAO'	,dDataBase					,NIL},;
		{'F1_FORNECE'	,_cFor						,NIL},;
		{'F1_LOJA'		,_cLoj				 		,NIL},;
		{'F1_ESPECIE'	,'SPED'						,NIL},;
		{'F1_XDOCIMP'	,cNumDI						,NIL},;
		{'F1_XNDI   '	,cNumDI						,NIL},;
		{'F1_XDTDI  '	,dDataDI					,NIL},;
		{'F1_XLOCDES'	,cLocDs						,NIL},;
		{'F1_XDTDES '	,dDataDs					,NIL},;
		{'F1_XINFOIM'	,cInfCom					,NIL}}
		
		For nCont := 1 To Len(aRetExcel)
			//³Ignora primeira linha pois se trata do cabecalho.						       ³
			If nCont <= 1
				Loop
			EndIf
			
			//³Ajusta e procura itens informados na planilha.							       ³
			cCod	:= 	FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"Código de Barras")]))
			cDescr	:= 	FwNoAccent(Alltrim(aRetExcel[nCont][aScan(aEstrut,"Descrição Resumida")]))
			nQuant	:= 	Val(Replace(aRetExcel[nCont][aScan(aEstrut,"Quantidade")],",","."))
			nVlUnit	:= 	Val(Replace(aRetExcel[nCont][aScan(aEstrut,"CIF Total em R$")],",","."))  
			nVlImp	:=	Val(Replace(aRetExcel[nCont][aScan(aEstrut,"Valor do Imposto de Importação")],",","."))  
			If Val(Replace(aRetExcel[nCont][aScan(aEstrut,"Aliquota IPI")],",",".")) < 1
				nIpi	:= Val(Replace(aRetExcel[nCont][aScan(aEstrut,"Aliquota IPI")],",",".")) * 100 
			else
				nIpi	:= Val(Replace(aRetExcel[nCont][aScan(aEstrut,"Aliquota IPI")],",","."))
			Endif	
			cPicm	:= SubStr(aRetExcel[nCont][aScan(aEstrut,"Aliquota ICMS")],3,2)
			
			nVlUnit	:=	nVlUnit/nQuant        
			nVlImp	:=	nVlImp/nQuant
			nValTot :=	nVlUnit+nVlImp
			
			//³Posiciona no produto e verifico se o mesmo esta cadastrado no sistema.	       ³
			DbSelectArea("SB1")
			DbSetOrder(1)
			If !DbSeek(xFilial("SB1")+cCod+Space(TamSx3("B1_COD")[1]-Len(cCod)))
				lRetorno := .F.
				Aadd(aProdEr,{cCod,cDescr})
				Loop
			EndIf
			
			//³Enquanto não tiver erros de produtos não cadastrados adiciono no array itens.   ³
			If lRetorno
				aItens :=	{	{'D1_COD'	,SB1->B1_COD		,NIL},;
				{'D1_UM'		,SB1->B1_UM			,NIL},;
				{'D1_QUANT'		,nQuant				,NIL},;
				{'D1_VUNIT'		,nValTot			,NIL},;
				{'D1_TOTAL'		,nValTot * nQuant	,NIL},;
				{'D1_LOCAL'		,'01'				,NIL},;
				{'D1_IPI'		,nIpi		,NIL},;			
				{'D1_PICM'		,Val(cPicm)			,NIL},;
				{'D1_II'		,nVlImp*nQuant			,NIL},;				
				{'D1_CC'		,'1000100'  		,NIL}}
				
				AAdd(aLinha,aItens)
			EndIf
		Next
	
		//³Inicio Execauto para incluir o pre documento.								   ³
		If lRetorno
			Begin Transaction
			nOpc := 3
			MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aLinha, nOpc)
			
			If lMsErroAuto
				mostraerro()
			Else
				//³Ajusto a numeração no SX5.													   ³
				DbSelectArea("SX5")
				DbSetOrder(1)
				DbSeek(xFilial("SX5")+"01"+Alltrim(cSerie))
				RecLock("SX5",.F.)
				X5_DESCRI  := Soma1(cNumero)
				X5_DESCSPA  := Soma1(cNumero)
				X5_DESCENG := Soma1(cNumero)
				MsUnLock()
				
				MsgInfo ( " Pre documento de entrada importado com sucesso! ", cNumero )
			EndIf
			End Transaction
		Else
			//³Caso tenha erros de produtos não cadastrados será exibido um arquivo TXT na tela.³
			MsgInfo("Existem produtos não cadastrados!")
			FCriaTxt(aProdEr)
		EndIf
	EndIf
	
	RestArea(aArea)
Return(Nil)

/*
±±ºPrograma  ³CSCOM001  ºAutor  ³Fernando Lavor      º Data ³  03/10/15   º±±
±±ºDesc.     ³ Cria arquivo TXT com produtos erro.                        º±±
±±ºUso       ³ AP Especifico da controle.                                 º±±
*/
Static Function FCriaTxt(aArray)
	Local cFile		:= ""
	Local nH		:= 0
	Local cLocal	:="C:\TEMP"
	Local cBarra	:= If(IsSrvUnix(), "/", "\")
	Local nLoop		:= 0

	//³Inicia criacao do arquivo TXT com base no aArray.	                           ³
	cFile 	:= cLocal+cBarra+"ProdErro"+dtos(Date())+Replace(cHora:=Time(),":","")+"0001"+".txt"
	nH 		:= fCreate(cFile)

	//³Digita o cabeçalho do arquivo TXT.					                           ³
	fWrite(nH,	Padr(Alltrim("Código do produto "),25)+;
		Padr(Alltrim("Descrição do produto"),50)+chr(13)+chr(10))

	//³Escreve produtos não encontrados.					                           ³
	For nLoop := 1 to Len(aArray)
		fWrite(nH,	Padr(Alltrim(aArray[nLoop][1]),25)+;				//Codigo do produto  				Pos (1-15) 		T (15)
		Padr(Alltrim(aArray[nLoop][2]),50)+chr(13)+chr(10))			//Descrição do produto 				Pos (16-36) 	T (16)
	Next
	fClose(nH)

	//³Abre o arquivo na tela.								                           ³
	ShellExecute( "Open", "C:\Windows\System32\notepad.exe", cFile, "C:\", 1 )

Return(Nil)

/*
±±ºPrograma  ³MTR948Str ºAutor  ³Mary Hergert        º Data ³ 03/08/2006  º±±
±±ºDesc.     ³Montar o array com as strings a serem impressas na descr.   º±±
±±º          ³dos servicos e nas observacoes.                             º±±
±±º          ³Se foi uma quebra forcada pelo ponto de entrada, e          º±±
±±º          ³necessario manter a quebra. Caso contrario, montamos a linhaº±± 
±±º          ³de cada posicao do array a ser impressa com o maximo de     º±±
±±º          ³caracteres permitidos.                                      º±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ºParametros³cString: string completa a ser impressa                     º±±
±±º          ³nLinhas: maximo de linhas a serem impressas                 º±±
±±º          ³nTotStr: tamanho total da string em caracteres              º±±
±±ºUso       ³MATR968                                                     º±±
*/
Static Function Mtr968Mont(cString,nLinhas,nTotStr)
	Local aAux		:= {}
	Local aPrint	:= {}
	Local cMemo 	:= ""
	Local cAux		:= ""
	Local nX		:= 1
	Local nY 		:= 1
	Local nPosi		:= 1

	cString := SubStr(cString,1,nTotStr)

	For nY := 1 to Min(MlCount(cString,95),nLinhas)
		cMemo := MemoLine(cString,95,nY)

		// Monta a string a ser impressa ate a quebra
		Do While .T.
			nPosi 	:= At("|",cMemo)
			If nPosi > 0
				Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
				cMemo 	:= SubStr(cMemo,nPosi+1,Len(cMemo))
			Else
				If !Empty(cMemo)
					Aadd(aAux,{cMemo,.F.})
				Endif
				Exit
			Endif
		Enddo
	Next

	For nY := 1 to Len(aAux)
		cMemo := ""
		If aAux[nY][02]
			Aadd(aPrint,aAux[nY][01])
		Else
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
			Do While !aAux[nY][02]
				nY += 1
				If nY > Len(aAux)
					Exit
				Endif
				cMemo += Alltrim(aAux[nY][01]) + Space(01)
			Enddo
			For nX := 1 to Min(MlCount(cMemo,95),nLinhas)
				cAux := MemoLine(cMemo,95,nX)
				Aadd(aPrint,cAux)
			Next
		Endif
	Next
Return(aPrint)
