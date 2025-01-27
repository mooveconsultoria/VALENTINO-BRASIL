#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE 'TBICONN.CH'

/* Objetos da tela de Troca/Devolucao */
STATIC oGCliCod
STATIC oGCliNom
STATIC oGProCod
STATIC oGProNom
STATIC oGDatIni
STATIC oGDatFim
STATIC oBConsul
STATIC oLCupons
STATIC oBSair
STATIC oBConfir

/*/{Protheus.doc} SYTRCDEV
Funcao para executar a tela de troca/devolucao de mercadorias no PDV.
@author Douglas Telles
@since 15/03/2016
@version 1.0
/*/
User Function SYTRCDEV()
	STIExchangePanel( { || U_VIEWTRC() } )
Return

/*/{Protheus.doc} VIEWTRC
Prepara a tela de troca/devolucao.
@author Douglas Telles
@since 15/03/2016
@version 1.0
@return oMainPanel, Objeto com as propriedades da tela
/*/
User Function VIEWTRC()
	Local oPanelMVC	:= STIGetPanel() // Painel principal do dialog
	Local cCpfCli		:= IIF(FindFunction('STDFindCust'),IIF(Empty(STDFindCust()),CriaVar("A1_CGC",.F.),;
								STDFindCust()[2]),CriaVar("A1_CGC",.F.))
	Local cNomecli	:= Space(80)
	Local cProdCod	:= Space(80)
	Local cProdNom	:= Space(80)
	Local dDtIniVd	:= Space(8)
	Local dDtFimVd	:= Space(8)
	Local cCupomLi	:= ""
	Local oListFont	:= TFont():New("Courier New") // Fonte utilizada no listbox
	Local bSair		:= { || STIRegItemInterface() }
	Local bConfirm	:= { || SYINCRET()}
	Local bConsult	:= { || IIF(InfoOk(cCpfCli, cProdCod, dDtIniVd, dDtFimVd), SYCONRET(cCpfCli, cProdCod, dDtIniVd, dDtFimVd), NIL ) }
	Local bConsCpf	:= { || IIF(Empty(cCpfCli),cNomecli:='',cNomecli:=POSICIONE("SA1",3,xFilial("SA1")+cCpfCli,"A1_NOME")),oGCliNom:Refresh() }
	Local bConsPro	:= { || IIF(Empty(cProdCod),cProdNom:='',cProdNom:=ConsProd(cProdCod)),oGProNom:Refresh() }
	Local cTitLis
	Local oMainPanel

	Private nLargPanel	:= oPanelMVC:nWidth/2 	// Largura do Painel para controle de Pixels
	Private nAltPanel		:= oPanelMVC:nHeight/2	// Altura do Painel para controle de Pixels
	Private nRolComp		:= PosV(0) 				// Controle de linhas para adicionar componente no painel
	Private nColComp1		:= PosH(5)  				// Controle da 1 coluna para adicionar componente no painel
	Private nColComp2		:= PosH(50) 				// Controle de 2 coluna para adicionar componente no painel
	Private nWComp		:= PosH(40) 				// Controle de largura dos componentes
	Private nHComp		:= PosV(6)  				// Controle de altura dos componentes

	/**===============================================================================================**
	 ** Definicao do painel de controle dos componentes
	 **===============================================================================================**/
	oMainPanel	:= TPanel():New(00,00,'',oPanelMVC,,.F.,,,,nLargPanel,nAltPanel,.F.,.F.)

	/**===============================================================================================**
	 ** Titulo da operacao
	 **===============================================================================================**/
	oLblTit:= TSay():New(PosV(2),nColComp1,{|| "Troca/Devolução"},oMainPanel,,,,,,.T.,,,,)
	oLblTit:SetCSS( POSCSS (GetClassName(oLblTit), CSS_BREADCUMB ))

	/**===============================================================================================**
	 ** Label para identificar o campo de CPF do cliente
	 **===============================================================================================**/
	oLblCPF:= TSay():New(NewComp(.T.,.T.),nColComp1,{|| "CPF Cliente" }, oMainPanel,,,,,,.T.)
	oLblCPF:SetCSS( POSCSS (GetClassName(oLblCPF), CSS_LABEL_FOCAL ))

	/**===============================================================================================**
	 ** Campo para receber o CPF do cliente
	 **===============================================================================================**/
	oGCliCod:= TGet():New(NewComp(.T.,.F.),nColComp1,{|u| If(PCount()>0,cCpfCli:=u,cCpfCli)},oMainPanel,nWComp,;
	nHComp,"@R 999.999.999-99",{|| Empty(cCpfCli) .Or. CGC(AllTrim(cCpfCli))},,,,,,.T.,,,bConsCpf,,,,.F.,,,"cCpfCli")
	oGCliCod:SetCSS( POSCSS (GetClassName(oGCliCod), CSS_GET_NORMAL ))

	/**===============================================================================================**
	 ** Campo para apresentar o nome do usuario
	 **===============================================================================================**/
	oGCliNom:= TGet():New(NewComp(.F.),nColComp2,{|u| If(PCount()>0,cNomecli:=u,cNomecli)},oMainPanel,nWComp+(nWComp*0,4);
	,nHComp,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,,,"cNomecli")
	oGCliNom:SetCSS( POSCSS (GetClassName(oGCliNom), CSS_GET_FOCAL ))

	/**===============================================================================================**
	 ** Label para identificar o campo produto
	 **===============================================================================================**/
	oLblProd:= TSay():New(NewComp(.T.,.T.),nColComp1,{|| "Produto" }, oMainPanel,,,,,,.T.)
	oLblProd:SetCSS( POSCSS (GetClassName(oLblProd), CSS_LABEL_FOCAL ))

	/**===============================================================================================**
	 ** Campo para receber o codigo do produto ou o codigo de barras do produto
	 **===============================================================================================**/
	oGProCod:= TGet():New(NewComp(.T.,.F.),nColComp1,{|u| If(PCount()>0,cProdCod:=u,cProdCod)},oMainPanel,nWComp,;
	nHComp,"@!",{|| Empty(cProdCod) .Or. SeekProd(Alltrim(cProdCod)) },,,,,,.T.,,,bConsPro,,,,.F.,,,"cProdCod")
	oGProCod:SetCSS( POSCSS (GetClassName(oGProCod), CSS_GET_NORMAL ))

	/**===============================================================================================**
	 ** Campo para apresentar o nome do produto
	 **===============================================================================================**/
	oGProNom:= TGet():New(NewComp(.F.),nColComp2,{|u| If(PCount()>0,cProdNom:=u,cProdNom)},oMainPanel,nWComp+(nWComp*0,4);
	,nHComp,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,,,"cProdNom")
	oGProNom:SetCSS( POSCSS (GetClassName(oGProNom), CSS_GET_FOCAL ))

	/**===============================================================================================**
	 ** Label para identificar os campos data inicial e final da venda
	 **===============================================================================================**/
	oLblDtIn:= TSay():New(NewComp(.T.,.T.),nColComp1,{|| "Data Inicial e Final da Venda" }, oMainPanel,,,,,,.T.)
	oLblDtIn:SetCSS( POSCSS (GetClassName(oLblDtIn), CSS_LABEL_FOCAL ))

	/**===============================================================================================**
	 ** Campo para receber a data inicial da venda
	 **===============================================================================================**/
	oGDatIni:= TGet():New(NewComp(.T.,.F.),nColComp1,{|u| If(PCount()>0,dDtIniVd:=u,dDtIniVd)},oMainPanel,(nWComp/2),;
	nHComp,"@R 99/99/9999",{|| Empty(dDtIniVd) .Or. Len(dDtIniVd) == 8},,,,,,.T.,,,{|| .T. },,,,.F.,,,"dDtIniVd")
	oGDatIni:SetCSS( POSCSS (GetClassName(oGDatIni), CSS_GET_NORMAL ))

	/**===============================================================================================**
	 ** Campo para receber a data final da venda
	 **===============================================================================================**/
	oGDatFim:= TGet():New(NewComp(.F.),(nColComp1+(nWComp/2)+2),{|u| If(PCount()>0,dDtFimVd:=u,dDtFimVd)},oMainPanel,(nWComp/2),;
	nHComp,"@R 99/99/9999",{|| Empty(dDtFimVd) .Or. Len(dDtIniVd) == 8},,,,,,.T.,,,{|| .T. },,,,.F.,,,"dDtFimVd")
	oGDatFim:SetCSS( POSCSS (GetClassName(oGDatFim), CSS_GET_NORMAL ))

	/**===============================================================================================**
	 ** Botao para efetuar a consulta
	 **===============================================================================================**/
	oBConsul:= TButton():New(NewComp(.F.),(nColComp2+(nWComp/4)), "Consultar",oMainPanel,bConsult,;
	(nWComp/2)+(nWComp*0,4),nHComp+(nWComp*0,4),,,,.T.,,,,{|| .T.},,)
	oBConsul:SetCSS( POSCSS (GetClassName(oBConsul), CSS_BTN_FOCAL ))

	/**===============================================================================================**
	 ** Label para identificar a lista de cupons
	 **===============================================================================================**/
	cTitLis :=	" Filial" + Space(20) + "| Cupom" + Space(1) + "| Serie" + Space(1) + "| CPF" + Space(6) +;
	 			"| Data Cupom" + Space(1) + "| Item Cupom" + Space(1) + "| Produto" + Space(1) + "| Qtd" +;
	 			Space(1) + "| Valor Unit."
	oLblList:= TSay():New(NewComp(.T.,.T.),nColComp1,{|| cTitLis },;
	oMainPanel,,,,,,.T.)
	oLblList:SetCSS( POSCSS (GetClassName(oLblList), CSS_LABEL_FOCAL ))

	/**===============================================================================================**
	 ** Listbox para listar os cupons consultados
	 **===============================================================================================**/
	oLCupons:= TListBox():Create(oMainPanel,NewComp(.T.,.F.),nColComp1,{|u| If(PCount()>0,cCupomLi:=u,cCupomLi)},,;
	PosH(92),PosV(30),,,,,.T.,,bConfirm,oListFont)
	oLCupons:SetCSS( POSCSS (GetClassName(oLCupons), CSS_LISTBOX ))

	/**===============================================================================================**
	 ** Botao para gerar a NCC
	 **===============================================================================================**/
	oBConfir:= TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,"Confirmar",oMainPanel,bConfirm,LARGBTN,ALTURABTN,,,,.T.)
	oBConfir:SetCSS( POSCSS (GetClassName(oBConfir), CSS_BTN_FOCAL ))

	/**===============================================================================================**
	 ** Botao para cancelar a geracao de NCC
	 **===============================================================================================**/
	oBSair:= TButton():New(POSVERT_BTNFOCAL,PosH(5),"Sair",oMainPanel,bSair,LARGBTN,ALTURABTN,,,,.T.)
	oBSair:SetCSS( POSCSS (GetClassName(oBSair), CSS_BTN_ATIVO ))

	oGCliCod:SetFocus()
Return oMainPanel

/*/{Protheus.doc} SYCONRET
Efetua conexão com a Retaguarda para consulta da origem.
@author Douglas Telles
@since 21/03/2016
@version 1.0
@param cCpfCli, caracter, CPF a ser consultado.
@param cProdCod, caracter, Produto a ser consultado.
@param dDtIniVd, data, Data inicial do período a ser consultado.
@param dDtFimVd, data, Data final do período a ser consultado.
@return lRet, Indica se a conexão foi efetuado com êxito.
/*/
Static Function SYCONRET(cCpfCli, cProdCod, dDtIniVd, dDtFimVd)
	Local oRemoteCall	:= NIL // Retorna da chamada da funcao na Retaguarda
	Local aRet			:= {}
	Local lRet			:= .F.
	Local lConting	:= .F.
	Local cErrMsg		:= ''
	Local nX
	Local aTRB01

	CursorWait()
	STFMessage(ProcName(),"STOP","Consultando Documentos na Retaguarda. Aguarde...")
	STFShowMessage(ProcName())

	// Prepara ambiente para conexao na Retaguarda
	cIP			:= GetMv("MV_LJILLIP",    .F. )
	nPorta		:= val(GetMv("MV_LJILLPO",.F.))
	cAmbiente	:= GetMv("MV_LJILLEN",    .F. )

	// Conecta no ambiente
	oRpcSrv := TRpc():New( cAmbiente )
	If ( oRpcSrv:Connect( cIP, nPorta ) )
		aTRB01 := oRpcSrv:CallProcEX('U_SYCONORI', cEmpAnt, cFilAnt, cCpfCli, cProdCod, dDtIniVd, dDtFimVd)

		If !(aTRB01 == Nil)
			For nX := 1 to len(aTRB01)
				aAdd(aRet,	Alltrim(aTRB01[nX][1])									+ ' | ' +;	// (TRB01)->D2_FILIAL
							Alltrim(aTRB01[nX][2])									+ ' | ' +;	// (TRB01)->D2_DOC
							Alltrim(aTRB01[nX][3])									+ ' | ' +;	// (TRB01)->D2_SERIE
							Transform(aTRB01[nX][4], "@R 999.999.999-99")			+ ' | ' +;	// (TRB01)->A1_CGC
							DTOC(STOD(aTRB01[nX][5]))								+ ' | ' +;	// (TRB01)->D2_EMISSAO
							Alltrim(aTRB01[nX][6])									+ ' | ' +;	// (TRB01)->D2_ITEM
							Alltrim(aTRB01[nX][7])									+ ' | ' +;	// (TRB01)->D2_COD
							Alltrim(Transform(aTRB01[nX][8], "@E 9,999,999"))	+ ' | ' +;	// (TRB01)->D2_QUANT
							Alltrim(Transform(aTRB01[nX][9], "@E 999,999,999,999.99")))		// (TRB01)->D2_PRCVEN
			Next nX

			oLCupons:SetArray(aRet)
			oLCupons:SetFocus()

			If !Empty(aRet)
				lRet := .T.
				STFMessage(ProcName(),"STOP","Documentos encontrados!")
				STFShowMessage(ProcName())
			Else
				STFMessage(ProcName(),"STOP","Não foi localizado Documentos para Devolução.")
				STFShowMessage(ProcName())
			EndIf
		Else
			oLCupons:SetArray({})
			STFMessage(ProcName(),"STOP","Ocorreu um Erro Inesperado na Retaguarda. Informe o Administrador.")
			STFShowMessage(ProcName())
		EndIf

		CursorArrow()

		// Fecha conexao
		oRpcSrv:Disconnect()
	Else
		CursorArrow()
		STFMessage(ProcName(),"STOP","Ocorreu um erro na conexão com a Retaguarda.")
		STFShowMessage(ProcName())
	EndIf
Return lRet

/*/{Protheus.doc} SYCONORI
Efetua a consulta da origem na Retaguarda.
@author Douglas Telles
@since 21/03/2016
@version 1.0
@param cCpfCli, caracter, CPF a ser consultado.
@param cProdCod, caracter, Produto a ser consultado.
@param dDtIniVd, data, Data inicial do período a ser consultado.
@param dDtFimVd, data, Data final do período a ser consultado.
@return aDocs, Documentos encontrados para a consulta solicitada.
/*/
User Function SYCONORI(cEmpEnv, cFilEnv, cCpfCli, cProdCod, dDtIniVd, dDtFimVd)
	Local cQuery	:= ""
	Local aDocs	:= {}
	Local cTmpDtIni
	Local cTmpDtFim
	Local TRB01

	RPCSetType(3)

	PREPARE ENVIRONMENT EMPRESA cEmpEnv FILIAL cFilEnv TABLES 'SD2,SA1,SB1' MODULO 'COM'

	TRB01 := CriaTrab(,.F.)

	cQuery := "SELECT "+ CRLF
	cQuery += "	SD2.D2_FILIAL "+ CRLF
	cQuery += "	,SD2.D2_DOC "+ CRLF
	cQuery += "	,SD2.D2_SERIE "+ CRLF
	cQuery += "	,SA1.A1_CGC "+ CRLF
	cQuery += "	,SD2.D2_EMISSAO "+ CRLF
	cQuery += "	,SD2.D2_ITEM "+ CRLF
	cQuery += "	,SD2.D2_COD "+ CRLF
	cQuery += "	,SD2.D2_QUANT "+ CRLF
	cQuery += "	,SD2.D2_PRCVEN "+ CRLF
	cQuery += "FROM " + RetSqlName("SD2") + " SD2 "+ CRLF
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1 "+ CRLF
	cQuery += "	ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "+ CRLF
	cQuery += "	AND SA1.A1_COD = SD2.D2_CLIENTE "+ CRLF
	cQuery += "	AND SA1.A1_LOJA = SD2.D2_LOJA "+ CRLF
	If !Empty(cCpfCli)
		cQuery += "	AND SA1.A1_CGC = '" + cCpfCli + "' "+ CRLF
	EndIf
	cQuery += "	AND SA1.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "WHERE "+ CRLF
	cQuery += "	SD2.D2_VALDEV <> SD2.D2_PRCVEN AND " + CRLF
	If !Empty(cProdCod)
		cQuery += "	(SD2.D2_COD = '" + AllTrim(cProdCod) + "' OR " + CRLF
		cQuery += "	SD2.D2_COD = "
		cQuery += 		"(SELECT TOP(1) B1_COD FROM " + RetSqlName("SB1") + " SB1 "
		cQuery += 		"WHERE B1_CODBAR = '" + AllTrim(cProdCod) + "' AND SB1.D_E_L_E_T_ = ' ') )AND " + CRLF
	EndIf
	If !Empty(dDtIniVd) .And. !Empty(dDtFimVd)
		cTmpDtIni := substr(dDtIniVd,5) + substr(dDtIniVd,3,2) + substr(dDtIniVd,1,2) 
		cTmpDtFim := substr(dDtFimVd,5) + substr(dDtFimVd,3,2) + substr(dDtFimVd,1,2)
		cQuery += "	SD2.D2_EMISSAO BETWEEN '" + cTmpDtIni + "' AND '" + cTmpDtFim + "' AND"+ CRLF
	EndIf
	cQuery += "	SD2.D_E_L_E_T_ = ' ' "+ CRLF

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),TRB01,.T.,.T.)

	While !EOF()
		AADD( aDocs, {(TRB01)->D2_FILIAL + ' - ' + POSICIONE("SM0",1,cEmpAnt+(TRB01)->D2_FILIAL,"SM0->M0_FILIAL"),;
						(TRB01)->D2_DOC,;
						(TRB01)->D2_SERIE,;
						(TRB01)->A1_CGC,;
						(TRB01)->D2_EMISSAO,;
						(TRB01)->D2_ITEM,;
						(TRB01)->D2_COD,;
						(TRB01)->D2_QUANT,;
						(TRB01)->D2_PRCVEN })
			DbSkip()
	EndDo

	DbCloseArea()

	RpcClearEnv()
Return (aDocs)

/*/{Protheus.doc} SYINCRET
Efetua a conexão com a Retaguarda para inclusão do documento de entrada.
@author Douglas Telles
@since 21/03/2016
@version 1.0
@return lRet, Indica se a conexão foi efetuado com êxito.
/*/
Static Function SYINCRET()
	Local oRemoteCall	:= NIL // Retorna da chamada da funcao na Retaguarda
	Local lRet			:= .T.
	Local aDados		:= {}
	Local aResRet		:=	{.F.,''}
	Local cCodVnd

	Private nQtdDev := 1
	Private cCliCrd := Space(TamSx3("A1_CGC")[1])
	Private cNomCrd := Space(40)

	If Len(oLCupons:aItems) > 0 .AND. oLCupons:nAt > 0
		aDados	:= STRTOKARR(oLCupons:aItems[oLCupons:nAt], '|')
	Else
		STFMessage(ProcName(),"STOP","Necessário Selecionar Documento")
		STFShowMessage(ProcName())
		Return .F.
	Endif

	If val(aDados[8]) > 1
		If INFOCOMP(1, val(aDados[8]))
			lRet := INFOCOMP(2)
		Else
			lRet := .F.
		EndIf
	Else
		lRet := INFOCOMP(2)
	EndIf

	If lRet
		If LEN(aDados) > 0
			aDados := AjADados(aDados)
		EndIf

		// Prepara ambiente para conexao na Retaguarda
		cIP			:= GetMv("MV_LJILLIP",    .F. )
		nPorta		:= val(GetMv("MV_LJILLPO",.F.))
		cAmbiente	:= GetMv("MV_LJILLEN",    .F. )

		// Conecta no ambiente
		oRpcSrv := TRpc():New( cAmbiente )
		If ( oRpcSrv:Connect( cIP, nPorta ) )

			STFMessage(ProcName(),"STOP","Gerando a Nota de Devolução. Aguarde...")
			STFShowMessage(ProcName())

			CursorWait()

			// Executa o ExecAuto na retaguarda
			aResRet := oRpcSrv:CallProcEX('U_SYINCTRC', cEmpAnt, cFilAnt, xNumCaixa(), nQtdDev, cCliCrd, aDados)

			If aResRet == Nil
				lRet := .F.
				CursorArrow()
				STFMessage(ProcName(),"STOP","Ocorreu um Erro Inesperado na Retaguarda. Informe o Administrador.")
				STFShowMessage(ProcName())
			Else
				lRet := aResRet[1]

				If lRet
					CursorArrow()

					STFMessage(ProcName(),"STOP","NCC Gerada com Sucesso!")
					STIRegItemInterface()
					STFShowMessage(ProcName())
				Else
					CursorArrow()
					STFMessage(ProcName(),"STOP",aResRet[2] + "Informe o Administrador.")
					STFShowMessage(ProcName())
				EndIf
			EndIf

			// Fecha conexao
			oRpcSrv:Disconnect()
		Else
			CursorArrow()
			STFMessage(ProcName(),"STOP","Não há conexão com a Retaguarda.")
			STFShowMessage(ProcName())
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} SYINCTRC
Efetua o ExecAuto do documento de entrada na Retaguarda.
@author Douglas Telles
@since 21/03/2016
@version 1.0
@param aDados, array, Dados da inclusão do documento de entrada.
@return aRet, Indica se o documento foi incluido e o erro caso tenha ocorrido.
/*/
User Function SYINCTRC(cEmpEnv, cFilEnv, cCaixa, nQtdDev, cCliCrd, aDados)
	Local cSerie		:= ''
	Local cDoc			:= ''
	Local cCodCli		:= ""
	Local cLojCli		:= ""
	Local aCabPc		:= {}
	Local aItemPc		:= {}
	Local aLinha		:= {}
	Local cTES			:= ''
	Local aRet			:= {.F.,''}

	Private lMSErroAuto 		:= .F.
	Private lMSHelpAuto 		:= .T.

	RPCSetType(3)

	PREPARE ENVIRONMENT EMPRESA cEmpEnv FILIAL cFilEnv TABLES 'SA1,SD2,SF4,SF1,SD1' MODULO 'COM' 
	Conout("Iniciou a inclusao na NCC!")

	cSerie 	:= SuperGetMv("MV_LJNFTRO",,"") // Serie Padrao de Devolucao
	cDoc		:= MA461NumNf( .T., cSerie )

	// Posiciona no cliente de origem
	DbSelectArea("SA1")
	DbSetOrder(3) // FILIAL + CGC
	If DbSeek(xFilial("SA1")+aDados[4])
		cCodCli := SA1->A1_COD
		cLojCli := SA1->A1_LOJA

		// Posiciona na nota de origem
		DbSelectArea("SD2")
		DbSetOrder(3) // FILIAL + DOC + SERIE + CLIENTE + LOJA + COD + ITEM
		If DbSeek(aDados[1]+aDados[2]+aDados[3]+cCodCli+cLojCli+aDados[7]+aDados[6])

			// Posiciona na TES de saida para encontra a TES de devolucao
			DbSelectArea("SF4")
			DbSetOrder(1) // FILIAL + CODIGO
			If DbSeek(xFilial("SF4")+SD2->D2_TES)
				aRet[1] := .T.
				cTES    := SF4->F4_TESDV
			Else
				aRet[1] := .F.
				aRet[2] := 'NCC não gerada. TES de Devolução não encontrada. '
			EndIf
		Else
			aRet[1] := .F.
			aRet[2] := 'NCC não gerada. Nota de origem não encontrada. '
		EndIf
	Else
		aRet[1] := .F.
		aRet[2] := 'NCC não gerada. Cliente de origem não encontrado. '
	EndIf

	Conout(IIF(Empty(aRet[2]),'Prepadando dados para gerar NCC!',aRet[2]))
	If aRet[1]
		If SA1->(DbSeek(xFilial("SA1")+cCliCrd))
			cCodCli := SA1->A1_COD
			cLojCli := SA1->A1_LOJA

			aadd( aCabPc, { "F1_FILIAL"		,xFilial("SF1")				, Nil })
			aadd( aCabPc, { "F1_DOC"			,AvKey(cDoc,"F1_DOC")		, Nil })
			aadd( aCabPc, { "F1_SERIE"		,AvKey(cSerie,"F1_SERIE")	, Nil })
			aadd( aCabPc, { "F1_TIPO"		,"D"							, Nil })
			aadd( aCabPc, { "F1_FORNECE"	,AvKey(cCodCli,"F1_FORNECE"), Nil })
			aadd( aCabPc, { "F1_LOJA"		,AvKey(cLojCli,"F1_LOJA")	, Nil })
			aAdd( aCabPc, { "F1_EMISSAO"	,dDataBase						, Nil })
			aadd( aCabPc, { "F1_FORMUL"     ,"S"							, Nil })
			aadd( aCabPc, { "F1_ESPECIE"    ,AvKey("NFE","F1_ESPECIE")	, Nil })

			AAdd( aLinha, { "D1_FILIAL"    	, xFilial("SD1")				, Nil })
			AAdd( aLinha, { "D1_COD"    	, AvKey(aDados[7],"D1_COD")	, Nil })
			AAdd( aLinha, { "D1_QUANT"  	, nQtdDev						, Nil })
			AAdd( aLinha, { "D1_VUNIT"  	, aDados[9]					, Nil })
			AAdd( aLinha, { "D1_TOTAL"  	, nQtdDev*aDados[9]			, Nil })
			AAdd( aLinha, { "D1_TES" 		, cTES							, Nil })
			AAdd( aLinha, { "D1_UM"     	, "PC"							, Nil })
			AAdd( aLinha, { "D1_NFORI"  	, aDados[2]					, Nil })
			AAdd( aLinha, { "D1_SERIORI"	, aDados[3]					, Nil })
			aAdd( aLinha, { "D1_ITEMORI"	, aDados[6]					, Nil })
			aAdd( aLinha, { "D1_VLORI"		, aDados[9]					, Nil })

			AADD(aItemPc,aLinha)

			SA1->(DbCloseArea())
			SD2->(DbCloseArea())
			SF4->(DbCloseArea())

			Conout("Iniciando o MSExecAuto da NCC!")
			MSExecAuto({|x,y,z|MATA103(x,y,z)},aCabPc, aItemPc,3,Nil)
			Conout("Finalizou o MSExecAuto da NCC!")
			If lMsErroAuto
				aRet[1] := .F.
				aRet[2] := 'Erro na Gravação da NCC. '

				cArqLog := "SYINCTRC"+DToS(dDataBase)+Left(Time(),2)+SubStr(Time(),4,2)+Right(Time(),2)+".LOG"
				MakeDir("\Erros\")
				Conout("Verificar o arquivo -> " + cArqLog)

				lMsErroAuto := .F.
				MostraErro("\Erros\", cArqLog)

				DisarmTransaction()
			Else
				aRet[1] := .T.
				aRet[2] := 'NCC Gerada com Sucesso! '
				Conout(aRet[2])

				// Atualiza os dados do documento de entrada de acordo com os processos do loja
				U_SYLJ720N(cDoc,cSerie,cCodCli,cLojCli,Nil,cCaixa,Nil)
				Conout("Executou U_SYLJ720N")

				// Executa Ponto de entrada desenvolvido pela equipe da Prada
				If Findfunction("U_LJ720FIM")
					ConOut("Inicio da execucao do P.E. U_lLJ720FIM pela rotina de troca e devolucao no PDV.")
					U_LJ720FIM()
					ConOut("Fim da execucao do P.E. U_lLJ720FIM pela rotina de troca e devolucao no PDV.")
				EndIf
			Endif
		Else
			aRet[1] := .F.
			aRet[2] := 'Cliente a receber NCC não encontrado na Retaguarda. '
			Conout(aRet[2])
		EndIf
	EndIf

	RpcClearEnv()
Return (aRet)

/*/{Protheus.doc} SYLJ720N
Autaliza dos dados do documento de entrada de acordo com os processos do loja.
@author Douglas Telles
@since 22/03/2016
@version 1.0
@param cNewDoc, caracter, Número do documento gerado.
@param cSerie, caracter, Número da série gerada.
@param cCliente, caracter, Cliente da devolução.
@param cLoja, caracter, Loja do cliente da devolução.
@param cMotivo, caracter, Motivo da troca.
@param cCaixa, caracter, Caixa que efetuou a troca.
@param cFilDocOri, caracter, Filial de origem.
/*/
User Function SYLJ720N(cNewDoc,cSerie,cCliente,cLoja,cMotivo,cCaixa,cFilDocOri)
	Local aArea		:= GetArea()		//Salva ambiente
	Local cPrefixoEnt	:= ""				//Prefixo da nota de entrada
	Local lAchouSF1	:= .F.				//Se achou o SF1
	Local cUfCliDev	:= ""				// Uf do cliente da devolucao.
	Local lMotDevol	:= SF1->(FieldPos("F1_MOTIVO")) > 0
	Local lD1FILORI	:= SD1->(FieldPos("D1_FILORI")) > 0
	Local cNatNcc		:= SuperGetMV("MV_NATNCC")

	Default cMotivo		:= ""
	Default cCaixa 		:= xNumCaixa()
	Default cFilDocOri  	:= Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca os dados do SD1 criados e atualiza com os processos do loja³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SD1")
	DbSetOrder(1)
	If DbSeek( xFilial("SD1") + cNewDoc + cSerie + cCliente + cLoja )
		While !EOF() .AND. SD1->D1_FILIAL  == xFilial("SD1")	.AND. ;
				SD1->D1_DOC		== cNewDoc						.AND. ;
				SD1->D1_SERIE		== cSerie						.AND. ;
				SD1->D1_FORNECE	== cCliente					.AND. ;
				SD1->D1_LOJA		== cLoja

			RecLock("SD1", .F.)
			REPLACE SD1->D1_ORIGLAN	WITH "LO"
			REPLACE SD1->D1_NUMCQ	WITH cCaixa
			If lD1FILORI .And. cFilDocOri <> Nil
				SD1->D1_FILORI := cFilDocOri
			EndIf
			MsUnlock()

			DbSkip()
		EndDo
	EndIf

	DBSelectArea( "SA1" )
	DBSetOrder( 1 )
	If DBSeek( xFilial("SA1") + cCliente + cLoja )
		cUfCliDev	:= SA1->A1_EST
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca os dados do SF1 criado para atulizar controle do Sigaloja³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek( xFilial("SF1") + cNewDoc + cSerie + cCliente + cLoja )
		RecLock("SF1", .F.)
		REPLACE SF1->F1_ORIGLAN With "LO"
		REPLACE SF1->F1_EST     With cUfCliDev

		If lMotDevol
			REPLACE SF1->F1_MOTIVO	With cMotivo
		EndIf
		MsUnlock()

		lAchouSF1 := .T.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca o prefixo da nota de entrada para atualizar a NCC    ³
	//³Forma de devolucao: NCC    								      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAchouSF1
		cPrefixoEnt := SF1->F1_PREFIXO
	Else
		cPrefixoEnt := cSerie
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o portador da Nota de Credito de acordo com o Caixa da operacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SE1")
	DbSetOrder( 2 )
	If DbSeek( xFilial("SE1") + cCliente + cLoja + cPrefixoEnt + cNewDoc  )
		While !EOF() .AND. 	SE1->E1_FILIAL	== xFilial("SE1")	.AND. ;
				SE1->E1_CLIENTE					== cCliente		.AND. ;
				SE1->E1_LOJA						== cLoja			.AND. ;
				SE1->E1_PREFIXO					== cPrefixoEnt	.AND. ;
				SE1->E1_NUM						== cNewDoc

			RecLock("SE1",.F.)
			REPLACE SE1->E1_PORTADO WITH cCaixa
			REPLACE SE1->E1_NATUREZ WITH cNatNcc
			REPLACE SE1->E1_ORIGEM  WITH "LOJA720"
			REPLACE SE1->E1_STATUS  WITH "A"
			MsUnlock()

			DbSkip()
		EndDo
	EndIf

	RestArea(aArea)
Return .T.

/*/{Protheus.doc} ConsProd
Faz a pesquisa do codigo de produto digitado.
@author Douglas Telles
@since 21/03/2016
@version 1.0
@param cCod, caracter, Codigo a ser consultado.
@return cProd, Nome do produto consultado.
/*/
Static Function ConsProd(cCod)
	Local aAreaAtu := GetArea()
	Local cProd

	DbSelectArea("SB1")
	DbSelectArea("SLK")

	SB1->(DbSetOrder( 1 )) // FILIAL + COD
	If SB1->(DbSeek( xFilial("SB1") + cCod ))
		cProd := SB1->B1_DESC
	Else
		SB1->(DbSetOrder( 5 )) // FILIAL + CODBAR
		If SB1->(DbSeek( xFilial("SB1") + cCod ))
			cProd := SB1->B1_DESC
		Else
			SLK->(DbSetOrder(1)) // FILIAL + CODBAR
			If SLK->(DbSeek( xFilial("SLK") + cCod ))
				cCod := SLK->LK_CODIGO
				SB1->(DbSetOrder( 1 )) // FILIAL + COD
				If SB1->(DbSeek( xFilial("SB1") + cCod ))
					cProd := SB1->B1_DESC
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaAtu)
Return cProd

/*/{Protheus.doc} INFOCOMP
Tela de informações complementares.
@author Douglas Telles
@since 22/03/2016
@version 1.0
@param nTipo, numérico, Indica o tipo da tela que irá ser apresentada.
@param nQLim, numérico, Quantidade limite a ser escolhida no caso da tela 1.
@return lRet, Inidica se a tela foi confirmada com suas devidas validações.
/*/
Static Function INFOCOMP(nTipo, nQLim)
	Local lRet		:= .F.
	Local aArea	:= GetArea()
	Local oDlg		:= Nil
	Local cF3		:= 'SA1NCC'

	Default nQLim := 1

	DEFINE MSDIALOG oDlg TITLE "Dados Complementares..." FROM 203,188 TO 350,500 PIXEL

	If nTipo == 1 // Tela para quantidade de troca
		@ 005,005 TO 056,150 LABEL "Quantidade a Devolver" Pixel Of oDlg
		@ 015,010 Say "Quantidade: " Pixel Of oDlg
		@ 024,010 MsGet nQtdDev Size 80,08 Pixel VALID VldQtd(nQLim) PICTURE "@R 999" Of oDlg
	Else // Tela para informar cliente
		@ 005,005 TO 056,150 LABEL "Cliente a Ser Creditado" Pixel Of oDlg
		@ 015,010 Say "CPF do Cliente: " Pixel Of oDlg
		@ 024,010 MsGet cCliCrd Size 80,08 Pixel Of oDlg F3 cF3 VALID (CGC(cCliCrd) .AND. VldCpf()) PICTURE "@R 999.999.999-99" 
		@ 034,010 Say "Nome do Cliente: " Pixel Of oDlg
		@ 043,010 MsGet cNomCrd Size 80,08 Pixel Of oDlg WHEN .F.
	EndIf

	DEFINE SBUTTON FROM 060,010 TYPE 1 ACTION (lRet := .T.,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 060,060 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} VldQtd
Valida a quantidade informada para devolução
@author Douglas Telles
@since 22/03/2016
@version 1.0
@param nQLim, numérico, Quantidade limite a ser informada.
@return lRet, Indica se a validação foi positiva ou não.
/*/
Static Function VldQtd(nQLim)
	Local lRet := .F.

	If !Empty(nQtdDev)
		If nQtdDev > nQLim
			Alert("A Quantidade de devolução não pode ser maior do que a quantidade comprada!")
		Else
			lRet := .T.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} VldCpf
Valida o CPF informado para geração do crédito.
@author Douglas Telles
@since 22/03/2016
@version 1.0
@return lRet, Indica se as validações foram positivas ou não.
/*/
Static Function VldCpf()
	Local aArea		:= GetArea()
	Local lRet 		:= .F.
	Local lRet			:= .T.
	Local cCliPad		:= SuperGetMV("MV_CLIPAD") // Cliente padrao
	Local cLojaPad	:= SuperGetMV("MV_LOJAPAD")// Loja do cliente padrao
	Local cCliente
	Local cNome

	If !Empty(cCliCrd)
		DbSelectArea("SA1")
		DbSetOrder(3)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se o codigo informado pelo usuario existe³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DbSeek(xFilial("SA1")+cCliCrd)
			lRet		:= .T.
			cCliente	:= SA1->A1_COD
			cNome		:= SA1->A1_NOME
		EndIf

		If !lRet
			MsgStop("O cliente selecionado não está cadastrado!","O cliente selecionado não está cadastrado!")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se o cliente a receber o credito eh diferente do cliente³
		//³padrao                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			lRet := (AllTrim(cCliente) <> AllTrim(cCliPad))
			If !lRet
				MsgStop("Não é permitida a troca/devolução de mercadorias para o cliente padrão","Atenção")
			EndIf
		EndIf

		If lRet
			cNomCrd := cNome
		Else
			cNomCrd := ''
		EndIf
	Else
		cNomCrd := ''
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} InfoOk
Valida se as informações estão corretas para efetuar a consulta.
@author Douglas Telles
@since 20/03/2016
@version 1.0
@param cCpfCli, caracter, CPF a ser consultado
@param cProdCod, caracter, Código do produto a ser consultado
@param dDtIniVd, data, Data inicial do período a ser consultado
@param dDtFimVd, data, Data final do período a ser consultado
@return lRet, Indica se há informação coerente para consulta
/*/
Static Function InfoOk(cCpfCli, cProdCod, dDtIniVd, dDtFimVd)
	Local lRet := .F.

	If !Empty(cCpfCli)
		lRet := .T.
	EndIf

	If !Empty(cProdCod)
		lRet := .T.
	EndIf

	If !Empty(dDtIniVd) .And. !Empty(dDtFimVd)
		lRet := .T.
	EndIf

	If !lRet
		oLCupons:SetArray({})
		STFMessage(ProcName(),"STOP","Informe o CPF, Produto ou período à consultar.")
		STFShowMessage(ProcName())
	EndIf
Return lRet

/*/{Protheus.doc} NewComp
Adiciona um novo componente na tela
@author Douglas Telles
@since 16/03/2016
@version 1.0
@param lNewLine, logico, Indica se o componente ira ser adicionado em uma nova linha
@param lTitulo, logico, Indica se o componente e titulo de outro componente
@return nRolComp, Indica o numero em Pixels da posicao do componente
/*/
Static Function NewComp(lNewLine, lTitulo)
	Default lTitulo := .F.

	If lNewLine
		If lTitulo
			nRolComp += PosV(8)
		Else
			nRolComp += PosV(4)
		EndIf
	EndIf
Return nRolComp

/*/{Protheus.doc} SeekProd
Efetua a busca do produto para popular o campo nome do produto na tela
@author Douglas Telles
@since 17/03/2016
@version 1.0
@param cCod, caracter, Codigo a ser consultado
@return lRet, Indica se o produto foi encontrado
/*/
Static Function SeekProd(cCod)
	Local aAreaAtu := GetArea()
	Local lRet := .T.

	DbSelectArea("SB1")
	DbSetOrder(1)
	If DBSeek(xFilial("SB1") + cCod)
		lRet := .T.
	Else
		Alert("Produto não encontrado!")
	EndIf

	RestArea(aAreaAtu)
Return lRet

/*/{Protheus.doc} PosH
Retorna posição em pixels do % horizontal da tela.
@author Douglas Telles
@since 21/03/2016
@version 1.0
@param nPerc, numérico, Percentual a ser calculado.
@return nPos, Posição calculada de acordo com a porcentagem informada.
/*/
Static Function PosH(nPerc)
	Local nPos

	nPos := nLargPanel * (nPerc / 100)
Return nPos

/*/{Protheus.doc} PosV
Retorna posicao em pixels do % vertical da tela.
@author Douglas Telles
@since 21/03/2016
@version 1.0
@param nPerc, numérico, Percentual a ser calculado.
@return nPos, Posição calculada de acordo com a porcentagem informada.
/*/
Static Function PosV(nPerc)
	Local nPos

	nPos := nAltPanel * (nPerc / 100)
Return nPos

/*/{Protheus.doc} AjADados
Ajusta o Array aDados que o usuario selecionou.
@author Douglas Telles
@since 22/03/2016
@version 1.0
@param aDados, array, Array a ser ajustado.
@return aRet, Array ajustado
/*/
Static Function AjADados(aDados)
	Local aRet := aDados

	aRet[1] := Alltrim(substr(aDados[1],1,2))
	aRet[2] := AvKey(Alltrim(aDados[2]),'D2_DOC')
	aRet[3] := AvKey(Alltrim(aDados[3]),'D2_SERIE')
	aRet[4] := Alltrim(Transform(StrTran(aDados[4], '-', ''),'@R 999999999999999'))
	aRet[5] := CTOD(aDados[5])
	aRet[6] := Alltrim(aDados[6])
	aRet[7] := AvKey(Alltrim(aDados[7]),'D2_COD')
	aRet[8] := val(aDados[8])
	aRet[9] := Alltrim(StrTran(aDados[9],'.',''))
	aRet[9] := val(StrTran(aRet[9],',','.'))
Return aRet