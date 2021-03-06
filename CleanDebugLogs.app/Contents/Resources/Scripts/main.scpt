FasdUAS 1.101.10   ��   ��    k             l     ����  r       	  m      
 
 �    / * S S Y D B L * / 	 o      ���� 0 targetstring targetString��  ��        l     ��������  ��  ��        l   + ����  O    +    k    *       l   ��  ��    � z Need to save everything, in case some the target string has been added to some files since the last time they were saved.     �   �   N e e d   t o   s a v e   e v e r y t h i n g ,   i n   c a s e   s o m e   t h e   t a r g e t   s t r i n g   h a s   b e e n   a d d e d   t o   s o m e   f i l e s   s i n c e   t h e   l a s t   t i m e   t h e y   w e r e   s a v e d .      l    ��  ��   �� First I tried this:				save every document
		but that didn't work because it would try to save system files and get permissions errors, and other crap with other files.
		So then I tried this:
		tell application "/Developer/Applications/Xcode.app"	-- Need to save everything, in case some the target string has been added to some files since the last time they were saved.	repeat with aDocument in documents		log ("will try to save " & name of aDocument)		try			tell aDocument to save		end try	end repeatend tell
Now I didn't get AppleScript errors, but the stupid thing would still try and save  files that didn't need to be saved, or couldn't be saved, and display sheets in Xcode.
So now I do this:      �  �   F i r s t   I   t r i e d   t h i s : 	 	  	 	 s a v e   e v e r y   d o c u m e n t 
 	 	 b u t   t h a t   d i d n ' t   w o r k   b e c a u s e   i t   w o u l d   t r y   t o   s a v e   s y s t e m   f i l e s   a n d   g e t   p e r m i s s i o n s   e r r o r s ,   a n d   o t h e r   c r a p   w i t h   o t h e r   f i l e s . 
 	 	 S o   t h e n   I   t r i e d   t h i s : 
 	 	 t e l l   a p p l i c a t i o n   " / D e v e l o p e r / A p p l i c a t i o n s / X c o d e . a p p "  	 - -   N e e d   t o   s a v e   e v e r y t h i n g ,   i n   c a s e   s o m e   t h e   t a r g e t   s t r i n g   h a s   b e e n   a d d e d   t o   s o m e   f i l e s   s i n c e   t h e   l a s t   t i m e   t h e y   w e r e   s a v e d .  	 r e p e a t   w i t h   a D o c u m e n t   i n   d o c u m e n t s  	 	 l o g   ( " w i l l   t r y   t o   s a v e   "   &   n a m e   o f   a D o c u m e n t )  	 	 t r y  	 	 	 t e l l   a D o c u m e n t   t o   s a v e  	 	 e n d   t r y  	 e n d   r e p e a t  e n d   t e l l 
 N o w   I   d i d n ' t   g e t   A p p l e S c r i p t   e r r o r s ,   b u t   t h e   s t u p i d   t h i n g   w o u l d   s t i l l   t r y   a n d   s a v e     f i l e s   t h a t   d i d n ' t   n e e d   t o   b e   s a v e d ,   o r   c o u l d n ' t   b e   s a v e d ,   a n d   d i s p l a y   s h e e t s   i n   X c o d e . 
 S o   n o w   I   d o   t h i s :        I   ��  ��
�� .sysodlogaskr        TEXT   m     ! ! � " " x P l e a s e   m a k e   s u r e   t h a t   a l l   o p e n   d o c u m e n t s   i n   X c o d e   a r e   s a v e d .��     # $ # l   ��������  ��  ��   $  % & % r     ' ( ' n     ) * ) 1    ��
�� 
pnam * 4    �� +
�� 
proj + m    ����  ( o      ���� 0 projectname projectName &  , - , r    " . / . n      0 1 0 1     ��
�� 
pdir 1 4    �� 2
�� 
proj 2 m    ����  / o      ���� 0 
projectdir 
projectDir -  3 4 3 l  # #��������  ��  ��   4  5 6 5 l  # #�� 7 8��   7 M G The following is a kludge but the best I can do with broken AppleSript    8 � 9 9 �   T h e   f o l l o w i n g   i s   a   k l u d g e   b u t   t h e   b e s t   I   c a n   d o   w i t h   b r o k e n   A p p l e S r i p t 6  : ; : l  # #�� < =��   < � � Note that Xcode 4 stores source files for project Foo in folder �/Foo/Foo/, where the first Foo is the project folder and thhe second is that "source" folder.    = � > >>   N o t e   t h a t   X c o d e   4   s t o r e s   s o u r c e   f i l e s   f o r   p r o j e c t   F o o   i n   f o l d e r   & / F o o / F o o / ,   w h e r e   t h e   f i r s t   F o o   i s   t h e   p r o j e c t   f o l d e r   a n d   t h h e   s e c o n d   i s   t h a t   " s o u r c e "   f o l d e r . ;  ?�� ? r   # * @ A @ b   # ( B C B b   # & D E D o   # $���� 0 
projectdir 
projectDir E m   $ % F F � G G  / C o   & '���� 0 projectname projectName A o      ���� 0 	sourcedir 	sourceDir��    4    �� H
�� 
capp H m     I I � J J B / D e v e l o p e r / A p p l i c a t i o n s / X c o d e . a p p��  ��     K L K l     ��������  ��  ��   L  M N M l  , 5 O���� O r   , 5 P Q P I   , 3�� R���� 20 removelastpathcomponent removeLastPathComponent R  S T S o   - .���� 0 
projectdir 
projectDir T  U�� U m   . /��
�� boovfals��  ��   Q o      ���� 0 projectsdir projectsDir��  ��   N  V W V l  6 ? X���� X r   6 ? Y Z Y I   6 =�� [���� 20 removelastpathcomponent removeLastPathComponent [  \ ] \ o   7 8���� 0 projectsdir projectsDir ]  ^�� ^ m   8 9��
�� boovfals��  ��   Z o      ����  0 programmingdir programmingDir��  ��   W  _ ` _ l     ��������  ��  ��   `  a b a l  @ X c���� c r   @ X d e d J   @ T f f  g h g o   @ A���� 0 	sourcedir 	sourceDir h  i j i l  A F k���� k b   A F l m l o   A B����  0 programmingdir programmingDir m m   B E n n � o o  C a t e g o r i e s O b j C��  ��   j  p q p l  F K r���� r b   F K s t s o   F G����  0 programmingdir programmingDir t m   G J u u � v v  C l a s s e s O b j C��  ��   q  w�� w l  K P x���� x b   K P y z y o   K L����  0 programmingdir programmingDir z m   L O { { � | |  P r o t o c o l s O b j C��  ��  ��   e o      ���� 0 dirs  ��  ��   b  } ~ } l     ��������  ��  ��   ~   �  l  Y h ����� � r   Y h � � � I   Y d�� ����� 0 join   �  � � � m   Z ] � � � � �    �  ��� � o   ] `���� 0 dirs  ��  ��   � o      ���� 0 
dirsstring 
dirsString��  ��   �  � � � l     ��������  ��  ��   �  � � � l  i p ����� � r   i p � � � m   i l � � � � �   � o      ���� 0 directorylist directoryList��  ��   �  � � � l  q � ����� � X   q � ��� � � r   � � � � � b   � � � � � b   � � � � � o   � ����� 0 directorylist directoryList � o   � ����� 0 adir aDir � o   � ���
�� 
ret  � o      ���� 0 directorylist directoryList�� 0 adir aDir � o   t w���� 0 dirs  ��  ��   �  � � � l     ��������  ��  ��   �  � � � l  � � ����� � I  � ��� � �
�� .sysodlogaskr        TEXT � b   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � m   � � � � � � � V W i l l   d e l e t e   a n y   l i n e   c o n t a i n i n g   t h e   s t r i n g : � o   � ���
�� 
ret  � o   � ���
�� 
ret  � o   � ����� 0 targetstring targetString � o   � ���
�� 
ret  � o   � ���
�� 
ret  � m   � � � � � � � n i n   a n y   . c ,   . c p p   o r   . m   f i l e   i n   a n y   o f   t h e s e   d i r e c t o r i e s : � o   � ���
�� 
ret  � o   � ���
�� 
ret  � I   � ��� ����� 0 join   �  � � � m   � � � � � � �  
 
 �  ��� � o   � ����� 0 dirs  ��  ��   � o   � ���
�� 
ret  � o   � ���
�� 
ret  � m   � � � � � � � T w h i c h   h a s   b e e n   m o d i f i e d   i n   t h e   l a s t   h o u r s : � �� ���
�� 
dtxt � m   � � � � � � �  7 2��  ��  ��   �  � � � l     ��������  ��  ��   �  � � � l  � � ����� � r   � � � � � c   � � � � � n   � � � � � 1   � ���
�� 
ttxt � 1   � ���
�� 
rslt � m   � ���
�� 
long � o      ���� 0 gobackseconds goBackSeconds��  ��   �  � � � l  � ����� � r   � � � � b   � � � � b   � � � � b   � � � � � b   � � � � � b   � � � � � m   � � � � � � �  c l e a n L i n e s . p l   � o   � ����� 0 targetstring targetString � m   � � � � � � �    - s � l  � � ���� � ]   � � � � � m   � ��~�~ � o   � ��}�} 0 gobackseconds goBackSeconds��  �   � m   � � � � � � $   - v   - x c   - x c p p   - x m   � o  �|�| 0 
dirsstring 
dirsString � o      �{�{ 0 cmd  ��  ��   �  � � � l     �z�y�x�z  �y  �x   �  � � � l   ��w�v � O    � � � k   � �  � � � l �u � ��u   �RL I wish that I could create a new terminal window, get a reference to it, bring it to the front, and then "do script cmd" in that window.  But there seem to be bugs or omissions in Terminal's AppleScriptability which cause that to fail.  So, I do the following.  The disadvantage is that it brings all Terminal windows to the front.    � � � ��   I   w i s h   t h a t   I   c o u l d   c r e a t e   a   n e w   t e r m i n a l   w i n d o w ,   g e t   a   r e f e r e n c e   t o   i t ,   b r i n g   i t   t o   t h e   f r o n t ,   a n d   t h e n   " d o   s c r i p t   c m d "   i n   t h a t   w i n d o w .     B u t   t h e r e   s e e m   t o   b e   b u g s   o r   o m i s s i o n s   i n   T e r m i n a l ' s   A p p l e S c r i p t a b i l i t y   w h i c h   c a u s e   t h a t   t o   f a i l .     S o ,   I   d o   t h e   f o l l o w i n g .     T h e   d i s a d v a n t a g e   i s   t h a t   i t   b r i n g s   a l l   T e r m i n a l   w i n d o w s   t o   t h e   f r o n t . �  � � � I �t�s�r
�t .miscactvnull��� ��� null�s  �r   �  � � � l �q �q    I C The following command seems to always create a new session/window.    � �   T h e   f o l l o w i n g   c o m m a n d   s e e m s   t o   a l w a y s   c r e a t e   a   n e w   s e s s i o n / w i n d o w . � �p I �o�n
�o .coredoscnull��� ��� ctxt o  �m�m 0 cmd  �n  �p   � m  �                                                                                      @ alis    Z  Air2-1                     �Ȗ�H+   1��Terminal.app                                                    2<��g        ����  	                	Utilities     ���*      ���     1�� 1��  ,Air2-1:Applications: Utilities: Terminal.app    T e r m i n a l . a p p    A i r 2 - 1  #Applications/Utilities/Terminal.app   / ��  �w  �v   �  l     �l�k�j�l  �k  �j   	 l      �i
�i  
 Y S removeTrailingSlash indicates whether or not trailing slash should be removed too     � �   r e m o v e T r a i l i n g S l a s h   i n d i c a t e s   w h e t h e r   o r   n o t   t r a i l i n g   s l a s h   s h o u l d   b e   r e m o v e d   t o o  	  i      I      �h�g�h 20 removelastpathcomponent removeLastPathComponent  o      �f�f 0 apath aPath �e o      �d�d *0 removetrailingslash removeTrailingSlash�e  �g   k     �  r      n     1    �c
�c 
txdl 1     �b
�b 
ascr o      �a�a 0 oldastid    r     l    �`�_  m    !! �""  /�`  �_   n     #$# 1    
�^
�^ 
txdl$ 1    �]
�] 
ascr %&% r    '(' n    )*) 2    �\
�\ 
citm* o    �[�[ 0 apath aPath( l     +�Z�Y+ o      �X�X 0 	item_list  �Z  �Y  & ,-, r    ./. n    010 4   �W2
�W 
cobj2 m    �V�V��1 o    �U�U 0 	item_list  / o      �T�T 0 lastitem lastItem- 343 r    565 m    �S�S  6 o      �R�R 00 offsetfortrailingslash offsetForTrailingSlash4 787 Z    <9:�Q�P9 =   $;<; l   "=�O�N= I   "�M>�L
�M .corecnte****       ****> o    �K�K 0 lastitem lastItem�L  �O  �N  < m   " #�J�J  : k   ' 8?? @A@ l  ' '�IBC�I  B !  aPath has a trailing slash   C �DD 6   a P a t h   h a s   a   t r a i l i n g   s l a s hA EFE r   ' 4GHG n   ' 2IJI 7  ( 2�HKL
�H 
cobjK m   , .�G�G L m   / 1�F�F��J o   ' (�E�E 0 	item_list  H o      �D�D 0 	item_list  F M�CM r   5 8NON m   5 6�B�B O o      �A�A 00 offsetfortrailingslash offsetForTrailingSlash�C  �Q  �P  8 PQP r   = CRSR n   = ATUT 4  > A�@V
�@ 
cobjV m   ? @�?�?��U o   = >�>�> 0 	item_list  S o      �=�= 0 lastitem lastItemQ WXW r   D OYZY [   D M[\[ l  D K]�<�;] c   D K^_^ l  D I`�:�9` I  D I�8a�7
�8 .corecnte****       ****a o   D E�6�6 0 lastitem lastItem�7  �:  �9  _ m   I J�5
�5 
TEXT�<  �;  \ o   K L�4�4 00 offsetfortrailingslash offsetForTrailingSlashZ o      �3�3 0 	cutlength 	cutLengthX bcb r   P Uded n   P Sfgf 1   Q S�2
�2 
lengg o   P Q�1�1 0 apath aPathe o      �0�0 0 wholelength wholeLengthc hih r   V [jkj \   V Ylml o   V W�/�/ 0 wholelength wholeLengthm o   W X�.�. 0 	cutlength 	cutLengthk o      �-�- 0 	newlength 	newLengthi non Z   \ kpq�,�+p =  \ _rsr o   \ ]�*�* *0 removetrailingslash removeTrailingSlashs m   ] ^�)
�) boovtrueq r   b gtut \   b evwv o   b c�(�( 0 	newlength 	newLengthw m   c d�'�' u o      �&�& 0 	newlength 	newLength�,  �+  o xyx r   l qz{z o   l m�%�% 0 oldastid  { n     |}| 1   n p�$
�$ 
txdl} 1   m n�#
�# 
ascry ~~ r   r ���� c   r ��� l  r }��"�!� n   r }��� 7  s }� ��
�  
cha � m   w y�� � o   z |�� 0 	newlength 	newLength� o   r s�� 0 apath aPath�"  �!  � m   } ~�
� 
TEXT� o      �� 
0 answer   ��� L   � ��� o   � ��� 
0 answer  �   ��� l     ����  �  �  � ��� i    ��� I      ���� 0 join  � ��� o      �� 
0 joiner  � ��� o      �� 0 alist aList�  �  � k     E�� ��� r     	��� l    ���� \     ��� l    ���� I    ���
� .corecnte****       ****� o     �
�
 0 alist aList�  �  �  � m    �	�	 �  �  � o      �� 0 njoiners nJoiners� ��� r   
 ��� m   
 �� ���  � o      �� 
0 answer  � ��� r    ��� m    ��  � o      �� 0 i  � ��� X    B���� k   " =�� ��� r   " '��� b   " %��� o   " #�� 
0 answer  � o   # $�� 0 aitem aItem� o      �� 
0 answer  � ��� Z   ( 7��� ��� A  ( +��� o   ( )���� 0 i  � o   ) *���� 0 njoiners nJoiners� r   . 3��� b   . 1��� o   . /���� 
0 answer  � o   / 0���� 
0 joiner  � o      ���� 
0 answer  �   ��  � ���� r   8 =��� [   8 ;��� o   8 9���� 0 i  � m   9 :���� � o      ���� 0 i  ��  � 0 aitem aItem� o    ���� 0 alist aList� ��� l  C C��������  ��  ��  � ���� L   C E�� o   C D���� 
0 answer  ��  � ��� l     ��������  ��  ��  � ���� l     ��������  ��  ��  ��       ������ 
������  � �������������� 20 removelastpathcomponent removeLastPathComponent�� 0 join  
�� .aevtoappnull  �   � ****�� 0 targetstring targetString��  ��  � ������������ 20 removelastpathcomponent removeLastPathComponent�� ����� �  ������ 0 apath aPath�� *0 removetrailingslash removeTrailingSlash��  � 
���������������������� 0 apath aPath�� *0 removetrailingslash removeTrailingSlash�� 0 oldastid  �� 0 	item_list  �� 0 lastitem lastItem�� 00 offsetfortrailingslash offsetForTrailingSlash�� 0 	cutlength 	cutLength�� 0 wholelength wholeLength�� 0 	newlength 	newLength�� 
0 answer  � 
����!��������������
�� 
ascr
�� 
txdl
�� 
citm
�� 
cobj
�� .corecnte****       ****����
�� 
TEXT
�� 
leng
�� 
cha �� ���,E�O���,FO��-E�O��i/E�OjE�O�j j  �[�\[Zk\Z�2E�OkE�Y hO��i/E�O�j �&�E�O��,E�O��E�O�e  
�kE�Y hO���,FO�[�\[Zk\Z�2�&E�O�� ������������� 0 join  �� ����� �  ������ 
0 joiner  �� 0 alist aList��  � �������������� 
0 joiner  �� 0 alist aList�� 0 njoiners nJoiners�� 
0 answer  �� 0 i  �� 0 aitem aItem� �������
�� .corecnte****       ****
�� 
kocl
�� 
cobj�� F�j  kE�O�E�OjE�O /�[��l  kh ��%E�O�� 
��%E�Y hO�kE�[OY��O�� �����������
�� .aevtoappnull  �   � ****� k     ��  ��  ��  M��  V��  a��  ��  ���  ���  ���  ���  ���  �����  ��  ��  � ���� 0 adir aDir� 0 
���� I !������������ F�������� n u {���� ����� ����������� � � � ��� ��������� � ��� ��������� 0 targetstring targetString
�� 
capp
�� .sysodlogaskr        TEXT
�� 
proj
�� 
pnam�� 0 projectname projectName
�� 
pdir�� 0 
projectdir 
projectDir�� 0 	sourcedir 	sourceDir�� 20 removelastpathcomponent removeLastPathComponent�� 0 projectsdir projectsDir��  0 programmingdir programmingDir�� �� 0 dirs  �� 0 join  �� 0 
dirsstring 
dirsString�� 0 directorylist directoryList
�� 
kocl
�� 
cobj
�� .corecnte****       ****
�� 
ret 
�� 
dtxt
�� 
rslt
�� 
ttxt
�� 
long�� 0 gobackseconds goBackSeconds���� 0 cmd  
�� .miscactvnull��� ��� null
�� .coredoscnull��� ��� ctxt��!�E�O)��/ !�j O*�k/�,E�O*�k/�,E�O��%�%E�UO*�fl+ E�O*�fl+ E�O��a %�a %�a %a vE` O*a _ l+ E` Oa E` O '_ [a a l kh  _ �%_ %E` [OY��Oa _ %_ %�%_ %_ %a %_ %_ %*a  _ l+ %_ %_ %a !%a "a #l O_ $a %,a &&E` 'Oa (�%a )%a *_ ' %a +%_ %E` ,Oa - *j .O_ ,j /U��  ��   ascr  ��ޭ