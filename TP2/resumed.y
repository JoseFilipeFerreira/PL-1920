Caderno : Conceito*
        | Meta

Conceito : Documento "@triplos:" Triplos

Documento : "===" URI "@tit:" Conteudo          

Meta : (URI INV URI '.')*

Triplos : (URI Pares '.')*

Pares : Par*

Par   : Rel Comps                    

Comps : Comp*

Comp : URI                           
     | STR                           

Rel  : 'a'                           
     | URI                           

Conteudo : Paragrafo                     
         | Conteudo Paragrafo            

Paragrafo : CONTEUDO                    
          | H2                          
          | H3                          
          | H4                          
