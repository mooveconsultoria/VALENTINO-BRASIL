#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH" 

//***************************************************************************** 
//* Função : PEDVENDA
//* Objetivo : Gera pedido de venda a partir de um documento de entrada.
//* Autor    : Patrick Araujo - 16/06/2017
//*****************************************************************************
                                                                                 
User Function PEDVENDA()
 
Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local nX     := 0
Local cDoc   := ""
Local lOk    := .T.
Local aItem := {}
Local cC6item := "00"
 
PRIVATE lMsErroAuto := .F.
//****************************************************************
//* Abertura do ambiente
//****************************************************************

If lOk
    	ConOut("Inicio: "+Time())
        cDoc := GetSxeNum("SC5","C5_NUM")
        RollBAckSx8()
        aCabec := {}
        aItens := {}
        aadd(aCabec,{"C5_NUM"   ,cDoc,Nil})
        aadd(aCabec,{"C5_TIPO" ,"N",Nil})
        aadd(aCabec,{"C5_CLIENTE","999999",Nil})
        aadd(aCabec,{"C5_LOJACLI","00",Nil})
        aadd(aCabec,{"C5_LOJAENT","00",Nil})
        aadd(aCabec,{"C5_CONDPAG","001",Nil})
        aadd(aCabec,{"C5_NATUREZ","110000003",Nil})    

		dbSelectArea("SD1")
		dbSetOrder(3)
		SD1->(DbGoTop())
		If Dbseek(xFilial("SD1") + DTOS(SF1->F1_EMISSAO) + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )
		       
			While !SD1->(EOF()) .And. SD1->D1_DOC == SF1->F1_DOC .And. SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA
		            aadd(aItem,{SD1->D1_ITEM          	    		,; //[1] ITEM
		                        SD1->D1_COD           	    		,; //[2] PRODUTO
		                        SD1->D1_QUANT         	    		,; //[3] QUANTIDADE
		                        SD1->D1_VUNIT         	    		,; //[4] VALOR UNITARIO
		                        SD1->D1_VUNIT         	    		,; //[5] VALOR DE LISTA
		                        Round(SD1->(D1_VUNIT*D1_QUANT),2)       ,; //[6] VALOR TOTAL
		                        "762"                 	    		}) //[7] TES
			Dbskip()
			EndDo 
		
		Else
			MsgAlert("Não foi possivel gerar o pedido de venda !!!")
		EndIf	
		                       
		For nX := 1 To Len(aItem)
	 		aLinha := {}
	 		cC6item := Soma1(cC6item)
	   		aadd(aLinha,{"C6_ITEM",cC6item,Nil})
	   		aadd(aLinha,{"C6_PRODUTO",aItem[nX][2],Nil})
	   		aadd(aLinha,{"C6_QTDVEN",aItem[nX][3],Nil})
	   		aadd(aLinha,{"C6_PRCVEN",aItem[nX][4],Nil})
	   		aadd(aLinha,{"C6_PRUNIT",aItem[nX][5],Nil})
	   		aadd(aLinha,{"C6_VALOR",aItem[nX][6],Nil})
	   		aadd(aLinha,{"C6_TES","762",Nil})
	   		aadd(aItens,aLinha)
	 	Next nX
        //****************************************************************
        //* Inclusão via execauto             
        //****************************************************************
        MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, 3) 
        If !lMsErroAuto
            MsgAlert("Pedido de venda N. "+cDoc+" gerado com sucesso!")
        Else
            MostraErro()
        EndIf
        

EndIf

Return(.T.)