REBOL [
    Title: "Code walkthrough"
    Purpose: {Display a code file and walkthrough documentation in a
    window for browsing.}
]

;WALKTHROUGH:Purpose

;; [---------------------------------------------------------------------------]
;; [ This program is an aid for making a video walkthrough of a code file.     ]
;; [ It shows, side-by-side, the code file and some documetation about the     ]
;; [ code file.  To make the documentation in small bites, the code file       ]
;; [ contains markers at various points, and those same markers are part of    ]
;; [ the documentation.  The markers are shown in a text-list and it is        ]
;; [ possible to click on the markers in the list and have the related         ]
;; [ documentation appear, and also have the related part of the code appear.  ]
;; [ More specifically, the documentation file looks like this:                ]
;; [                                                                           ]
;; [ %(name-of-code-file)                                                      ]
;; [ (date)                                                                    ]
;; [ "walkthrough-point-1"                                                     ]
;; [ {multi-line walkthrough text 1}                                           ]
;; [ "walkthrough-point-2"                                                     ]
;; [ {multi-line walkthrough text 2}                                           ]
;; [ ...                                                                       ]
;; [ "walkthrough-point-n"                                                     ]
;; [ {multi-line walkthrough text n}                                           ]
;; [                                                                           ]
;; [ This text file of documentation has the extension of dot-walkthrough.     ]
;; [ When the program opens the file, it will load the file so it is           ]
;; [ REBOL-readable, and the file name on the first line is the code file      ]
;; [ that we will be walking through.                                          ]
;; [                                                                           ]
;; [ The code file is connected to the documentation file by markers at        ]
;; [ various points in the code.  Those markers have a specific and            ]
;; [ required format.  The format is:                                          ]
;; [     semicolon in first column (to make it a REBOL comment)                ]
;; [     WALKTHROUGH:                                                          ]
;; [     (the text of a walkthrough point, exact spelling, no quotes)          ]
;; [ For example,                                                              ]
;; [     ;WALKTHROUGH:walkthrough-point-1                                      ]
;; [     ;WALKTHROUGH:walkthrough-point-2                                      ]
;; [     ;WALKTHROUGH:walkthrough-point-n                                      ]
;; [ The names of the walkthrough points can be anything, they may include     ]
;; [ spaces.  The only requirement is that the name in the code must match     ]
;; [ the name in the documentation.                                            ]
;; [                                                                           ]
;; [ When the program runs it loads the walkthrough file with the "load"       ]
;; [ function.  It extracts the names and puts them into the text-list         ]
;; [ on the window.  Click on one of the names and the program will find       ]
;; [ the associated text in the documenation file and display it, and will     ]
;; [ locate that same walkthrough point in the code and display the code       ]
;; [ from that point onward.                                                   ]
;; [                                                                           ]
;; [ With the window on display, one can read the text and examine the code,   ]
;; [ or one can turn on a screen recorder and read through the documentation   ]
;; [ and page through the code, to explain what the code does.                 ]
;; [                                                                           ]
;; [ Note that the text of the walkthrough points should not have any          ]
;; [ commonality or you could mess up the process of paging through the        ]
;; [ code.  For example, if one point was "AAA BBB CCC" and a later one was    ]
;; [ "AAA BBB" then when you tried to go to "AAA BBB" the program would        ]
;; [ stop at "AAA BBB CCC" and never get to "AAA BBB" because every search     ]
;; [ starts from the beginning.                                                ]
;; [---------------------------------------------------------------------------]

;WALKTHROUGH:Common modules

;do %/cob-apps/VOL1/COB_REBOL_MODULES/cob.r

;WALKTHROUGH:My documentation

DEMO: false
MY-DOCUMENTATION: 
#{
789C8D58516FE3380E7ED7AF10021CF6252906FB74B87BEA4E3B33B9ED34839D
2EFAACD84A62C4B67C96DC4C70B8FF7E1F49C9969DCEE2803EA4964452E4C78F
A4FEF6D195F6D5D4E770EADD703CDDF54A7DF8FBE65FF7CF9B5F3FFCFA41A9D5
B7A1EF9CB72BA5FEF372AABCEE7A77EC4DA32FC6EBA2B726D852E3A769B5A94A
7D70BD6ECCB96A8FFAAD2AADD305E463EFA8C0DFA96DD065E5BBDA5C714C361C
AADAEAAE1EBCF6AE99EDD7C1FE086B7CC6D6CEF6DEB5BA30AD82E25243576F0F
B6D7C1E970B2BC158694DA9FDC85BF980EE6767D052B7567FAA0DD81BF9352C5
4A71B431A1388D02EEB4FECD868BB5EDB893654E0A7AAB7D705D874BAACE556D
F05834B2D098FE0C8754D9615203A12FF8DF9B663AABE5ACBA3DB6BC3E4EDFD7
352D79ABAB601BAF4FE60D923A5B5487AA50F03A2EE1F5E554E12624D0FE807F
AB566416AE692C99999975A795DAB6DA0F0D745FD7FCBD74C5401B4DA8E066BE
6C4521E25FECAD4B15C453F8625B8F6D0A1E2D5DD86436AFD95F151FFEE3F1B7
DDD3A676A634FBD10D87AAF7812F028B946C0CA78882967C948589BF8A7DDE16
8E25D34132AC445CD72A45A7B77E0CB0784942D5C3D99E17E81E1C2A5714434F
EEE80C6CB9530BABA2105A14450014C023A244C2A54244F68086568C41DB1656
223AF7B2C43D1A4EA26AD71E01D94C964AB262566440A8DA12483E30D04D8903
771CB5247ECDA0F633778D5004B26732279CA9FD95138F51A16BC084149A114F
5AF0C4C64398FC1783A4D2B1E2647A53045C05DA71D63655E170B935F6D7B5BB
4023D4A4AC51ABD7FBA7DF5FBEFCB1FBF3F3977FACA63D15A495949FF535ED9F
39FBD0BB86F5BE9314E4DA918EC88783B72C61E56D6D8B0035435B1098478C88
6C0182432C0A62065AA0B044C8DF242133C5DD7F41861F7179A446E3CAA1B65E
38D1B227A7AFBAA98EA740BE8FAEC22DDD30CAED867D0D17BF81CB6018410F8E
65E4032348591FCD393AF8C61C2D5D6A010836E5EB759EAF2341E78E92DCE1E0
C2980E1942C228A06B8A2742586E0835A42038152687C2BD1F4F065065BD6FA6
1E382B1F1EBFEE986EFB61A2C53C060AEC4F59B1B482415C0504E640647E7503
F13860637522EB28465D5C7FF67CC757FC22107036D3053F4108879194C09CB3
B54CA501503C4B1A50B2AFA58C544D87681B8075F5665004F61C33CA8355698B
1A3FCA953E2177194BF007FE5A17746B0B380AB4489E6306E3ABC2BE3D645C95
07743DBC7F6973BBD77A4F51E64439D9BA3B0C355F9AEBD010003C246F96059B
4FDBA7C7CDF621B15F4E7C4BB04B11991D4FC76EC34D6C8B888E5CBDA20F592E
78378B1A85615646474EA902547EDC3D3C3E6D9F1FBF2785CC325C7F0933BAB1
8DEBAF64DBEFDF76DBE797EF22CC93B4DC5C7320AEB82076E7AA830E1F22E713
EB868B531CE47556C3661540DC436110DA677C3CEDEE1F36999231079869D385
71C3BA961C420274AEF54C8E86E215B0EC66B945ED89F1673FC62EC5E51D4C93
39F647459595BC054858AF0841478B1AD352C4C00F2D2D91C3DE0F58EE46299D
C8783F39871D4306B3CFE933372C04FBC93B79280066DC8EF895D2C1AB146816
E1D195092180824B44A4AC0E5CBEC248B564B9142630521829E9B6299BA188C9
C2538A43640FF685292A228A04465952F4DE832DC7D6A321B1D24FA99F5D35F6
315C99E80AD4CA889B3D83CB4FE87A073E2533BED36E4FE6CCEB773437B74D4A
3A9DF6C9425754DCF572159A224C59E66748522F7F6102F13B05AD6A0F0EEBB6
C6612356A3418C876F2CF1B1BB0B5C7BCB2966AC810A2837DFCAA2BE5C53DFB1
28A5A8F8D22825896D7E173118AE8C34C2468EBE8C1D09145152915493CADFC8
2F1C1A08E0C2C55516B89DFA68D244C9FBFDCBEE751349234F5CBE4D4ADD242B
A6F0E514DB728759C00062BA403145B2721A5BF50E7DC64BA6A68CEA713F9B05
62B4A49D383A532729A311159359ECA4DEE7E70C16C4BB5249193AD22DD2B044
96DA5280BE90C7DEF101568D8152F1E0E22608D2A7D8A8E688BB6D8EB6F93ADB
98074D2D82B64EC5BC9D66B3D94845799D5DD2173D3A38DBABA9CAD0D0355599
E8CF851A10D0BF07B0C3385500CD4609AB27916B190447ED11415160FE890223
698C9E363364D1FC8D7DCA6D5E8FC1E938363208DC0A903EF1D6D5B37E3F6F18
6501796E58796FC3D0B7349F099AA516B272DEB9666EA8E31886C60413828A59
1BE716C4FD59C6978C7379FCF6B126A0B3EFC77CC1FC679920F261844A5B1A87
82438D42EFA357FF9C77E63F75D6DDC874C89E54A164E42002E363262940B45E
E36E5A8A8C2E6B6BFA5AB8AE2218A06B176A58B884ED1000534B154948C95EDC
1B0A9E1C8F44D9988EEF74F9520A589CB72FC831237446CC98CFF166EA22B6CF
9F769BD7EDF3C3EE7549464B0CB391D4353106A514F2AB8395F04C69A2264C53
3761DA6BA69A53941E549CF7D55E9E2278ACA7A21D95AA51E9DE1686C69BB123
4D1D346A9D977626339058AD44803D7389327392FBCB6C5CCF5231A241A1DA0C
A64EDC8266EFC4B58A469731CB780BC6388E00B7EDD24E17B5353D01C24AD4F9
6D40EC6A0154D374B83C35EC17EAC5A5D58E9DB4843DD782FD45A05951FCA12E
F46CD1FE12F4B9455D4AAB9268613425BEA060336FABE28B0DBFA8A8D46BCAEC
202BCDE07984232831483EEF362FF4F72D0D7D9DBC8BC5A1C32FABC50A6EB5E0
906C8C07FF124726104A63906A32933FDF9DDDF55E9B34113B35886A04F8129F
5C77E32CED38C7D3924C555FEFB7CF3F817A64965FBCFEFCE776EA6388374E34
F32CE794A9B9D95B3299A2496C9C71787CA3F1D4998010C60B2F1B4086D5CBE2
19277AAE9A2174ECCCE50924AF2469E5B657856731A08D0F7B14390C1DE9F426
B644EAFDEEE18ED366D97398DB9D6B1660BA2E3D3AA647B49BA79DE936B1BDEA
E9D5607ACC9A37BEFF9784DA1EB8B352FF03E078ACF9D5150000
}
if DEMO [
    write %CodeWalkthrough.walkthrough decompress MY-DOCUMENTATION
    alert "Select CodeWalkthrough.walkthrough to view my documentation."
]

;WALKTHROUGH:Working items

WALKTHROUGH-FILE-ID: none
WALKTHROUGH: []
CODELINES: ""
WKPOINTS: []

;WALKTHROUGH:LOAD-WALKTHROUGH

LOAD-WALKTHROUGH: does [
    if not WALKTHROUGH-FILE-ID: request-file/only/filter ["*.walkthrough"] [
        alert "No file requested"
        exit
    ]
    WALKTHROUGH: load WALKTHROUGH-FILE-ID 
    change-dir first split-path WALKTHROUGH-FILE-ID
    CODELINES: read first WALKTHROUGH
    WKPOINTS: skip WALKTHROUGH 2 ; Skip past code file name and date
    MAIN-CODE-ID/text: to-string first WALKTHROUGH
    show MAIN-CODE-ID
    MAIN-CODE-DATE/text: to-string second WALKTHROUGH
    show MAIN-CODE-DATE
    MAIN-POINTS/data: extract WKPOINTS 2
    show MAIN-POINTS
    LOAD-INFO-WINDOW MAIN-CODE MAIN-CODE-SCROLLER CODELINES
    show MAIN-CODE
    show MAIN-CODE-SCROLLER
]

;WALKTHROUGH:SHOW-WKPOINT

WKPOINT-TEXT: ""
SHOW-WKPOINT: does [
    LOAD-INFO-WINDOW MAIN-TEXT MAIN-TEXT-SCROLLER 
        select WALKTHROUGH first MAIN-POINTS/picked
    show MAIN-TEXT
    show MAIN-TEXT-SCROLLER
    WKPOINT-TEXT: copy ""
    WKPOINT-TEXT: rejoin [
        ";WALKTHROUGH:"
        MAIN-POINTS/picked
    ]
    CODELINES: head CODELINES
    WKPOINT-CODE: copy ""
    parse CODELINES [thru WKPOINT-TEXT copy WKPOINT-CODE to end]
    LOAD-INFO-WINDOW MAIN-CODE MAIN-CODE-SCROLLER WKPOINT-CODE
    show MAIN-CODE
    show MAIN-CODE-SCROLLER
]

;WALKTHROUGH:LOAD-INFO-WINDOW

;; -- Isolate the loading of a text area and its scroller because
;; -- we can use this function for the code and the walkthrough.
LOAD-INFO-WINDOW: func [TXT BAR TDATA] [
    TXT/text: TDATA
    TXT/para/scroll/y: 0
    TXT/line-list: none
    TXT/user-data: second size-text TXT
    BAR/data: 0
    BAR/redrag TXT/size/y / TXT/user-data
]

;WALKTHROUGH:GO-TO-TOP

GO-TO-TOP: does [
    LOAD-INFO-WINDOW MAIN-TEXT MAIN-TEXT-SCROLLER ""
    show MAIN-TEXT
    show MAIN-TEXT-SCROLLER
    CODELINES: head CODELINES
    LOAD-INFO-WINDOW MAIN-CODE MAIN-CODE-SCROLLER CODELINES
    show MAIN-CODE
    show MAIN-CODE-SCROLLER
]

;WALKTHROUGH:MAIN-WINDOW

MAIN-WINDOW: layout [
    across
;   image COB-LOGO
    banner "Code walkthrough" font [shadow: none size: 42 color: black]
    return
    MAIN-CODE-ID: info 200 
    MAIN-CODE-DATE: info 100 
    return
    MAIN-CODE: info 700x800 as-is
        font [style: 'bold size: 14 name: font-fixed]
    MAIN-CODE-SCROLLER: scroller 20x800
        [scroll-para MAIN-CODE MAIN-CODE-SCROLLER]
    MAIN-POINTS: text-list 250x800 
        font [style: 'bold size: 14 name: font-fixed]
        [SHOW-WKPOINT]
    MAIN-TEXT: area 600x800
        font [style: 'bold size: 14 name: font-fixed]
    MAIN-TEXT-SCROLLER: scroller 20x800
        [scroll-para MAIN-TEXT MAIN-TEXT-SCROLLER]
    return
    button 200 "Load walkthrough" [LOAD-WALKTHROUGH]
    button "Top" [GO-TO-TOP]
    button "Quit" [quit]
    button "Debug" [halt]
]

view center-face MAIN-WINDOW



