FasdUAS 1.101.10   ��   ��    k             l        	  j     �� 
�� 0 isdebugging isDebugging 
 m     ��
�� boovfals    make true for debugging    	 �   0   m a k e   t r u e   f o r   d e b u g g i n g      l     ��������  ��  ��        i        I     �� ��
�� .aevtoappnull  �   � ****  o      ���� 0 argv  ��    k    �       Z     D  ��   l     ����  =        o     ���� 0 isdebugging isDebugging  m    ��
�� boovtrue��  ��    k   
 >       l  
 
��   ��    X R Debugging Section.  Use these test arguments to test this script in Script Editor      � ! ! �   D e b u g g i n g   S e c t i o n .     U s e   t h e s e   t e s t   a r g u m e n t s   t o   t e s t   t h i s   s c r i p t   i n   S c r i p t   E d i t o r   " # " r   
  $ % $ J   
 ����   % o      ���� 0 args   #  & ' & l   �� ( )��   (   Path to .xcodeproj:    ) � * * (   P a t h   t o   . x c o d e p r o j : '  + , + r     - . - m     / / � 0 0 � / U s e r s / j k / D o c u m e n t s / P r o g r a m m i n g / P r o j e c t s / B o o k M a c s t e r / B o o k M a c s t e r . x c o d e p r o j . n       1 2 1  ;     2 o    ���� 0 args   ,  3 4 3 l   �� 5 6��   5   Target name:    6 � 7 7    T a r g e t   n a m e : 4  8 9 8 r     : ; : m     < < � = =  M a i n A p p - O S X 5 ; n       > ? >  ;     ? o    ���� 0 args   9  @ A @ l   �� B C��   B   New version string:    C � D D (   N e w   v e r s i o n   s t r i n g : A  E F E r     G H G m     I I � J J 
 1 . 2 . 4 H n       K L K  ;     L o    ���� 0 args   F  M�� M I   >�� N��
�� .sysodlogaskr        TEXT N b    : O P O b    5 Q R Q b    3 S T S b    . U V U b    , W X W b    * Y Z Y b    ( [ \ [ b    # ] ^ ] b    ! _ ` _ m     a a � b b � W A R N I N G .     S e t T a r g e t V e r s i o n   i s   u s i n g   h a r d - c o d e d   D e b u g   T e s t   p a r a m e t e r s .     I n   p r o j e c t : ` o     ��
�� 
ret  ^ o   ! "��
�� 
ret  \ n   # ' c d c 4   $ '�� e
�� 
cobj e m   % &����  d o   # $���� 0 args   Z o   ( )��
�� 
ret  X o   * +��
�� 
ret  V m   , - f f � g g " w i l l   s e t   t a r g e t   ' T n   . 2 h i h 4   / 2�� j
�� 
cobj j m   0 1����  i o   . /���� 0 args   R m   3 4 k k � l l  '     t o   v e r s i o n   P n   5 9 m n m 4   6 9�� o
�� 
cobj o m   7 8����  n o   5 6���� 0 args  ��  ��  ��    r   A D p q p o   A B���� 0 argv   q o      ���� 0 args     r s r l  E E��������  ��  ��   s  t u t l  E E�� v w��   v   Get arguments    w � x x    G e t   a r g u m e n t s u  y z y q   E E { { ������ 0 projectpath projectPath��   z  | } | Q   E u ~  � ~ k   H U � �  � � � r   H N � � � n   H L � � � 4   I L�� �
�� 
cobj � m   J K����  � o   H I���� 0 args   � o      ���� 0 projectpath projectPath �  ��� � r   O U � � � n   O S � � � 4   P S�� �
�� 
cobj � m   Q R����  � o   O P���� 0 args   � o      ���� 0 
targetname 
targetName��    R      ������
�� .ascrerr ****      � ****��  ��   � k   ] u � �  � � � r   ] h � � � b   ] d � � � b   ] b � � � b   ] ` � � � o   ] ^���� 0 
scriptname 
scriptName � m   ^ _ � � � � �� :   E r r o r :   i n v a l i d   a r g u m e n t s . 
 	 	 
 W h e n   u s e d   p r o p e r l y ,   t h i s   s c r i p t   w i l l   s e t   t h e   C U R R E N T _ P R O J E C T _ V E R S I O N   B u i l d   S e t t i n g   o f   a   d e s i g n a t e d   t a r g e t   w i t h i n   a   d e s i g n a t e d   X c o d e     p r o j e c t .  U s a g e   i s :          o s a s c r i p t   p o s i x / p a t h / t o / � o   ` a���� 0 
scriptname 
scriptName � m   b c � � � � �> . s c p t   p r o j e c t   t a r g e t N a m e   v e r s i o n  w h e r e 
         p r o j e c t   m a y   b e   e i t h e r   t h e   c o n s t a n t   C U R R E N T _ P R O J E C T   t o   i n d i c a t e   t h e   f r o n t m o s t   o p e n   p r o j e c t ,   o r   a   f u l l   p a t h   t o   a n   X c o d e   p r o j e c t   f i l e ,   s u c h   a s   / f u l l / p a t h / t o / M y P r o j e c t . x c o d e p r o j 
         t a r g e t N a m e   i s   t h e   n a m e   o f   a   t a r g e t   w i t h i n   t h a t   p r o j e c t          v e r s i o n   i s   t h e   o p t i o n a l   n e w   v e r s i o n   s t r i n g   w h i c h   w i l l   b e   s e t   a t   t h e   p r o j e c t   l a y e r .     E x a m p l e :   " 1 . 0 . 0 " .     I f   n o t   g i v e n ,   a   d i a l o g   w i l l   a s k . � o      ���� 0 msg   �  � � � l  i i�� � ���   � * $ The following will abort the script    � � � � H   T h e   f o l l o w i n g   w i l l   a b o r t   t h e   s c r i p t �  ��� � R   i u�� � �
�� .ascrerr ****      � **** � o   q t���� 0 msg   � �� ���
�� 
errn � m   m p����   �1��  ��   }  � � � l  v v��������  ��  ��   �  � � � l  v v�� � ���   � 8 2 For debugging, in case we don't get a projectName    � � � � d   F o r   d e b u g g i n g ,   i n   c a s e   w e   d o n ' t   g e t   a   p r o j e c t N a m e �  � � � r   v } � � � m   v y � � � � �  N O - P R O J E C T ! ! � o      ���� 0 projectname projectName �  � � � l  ~ ~��������  ��  ��   �  � � � l  ~ ~�� � ���   � f ` Note that we do this in Xcode 3 because the relevant AppleScriptability is broken in Xcode 4.1.    � � � � �   N o t e   t h a t   w e   d o   t h i s   i n   X c o d e   3   b e c a u s e   t h e   r e l e v a n t   A p p l e S c r i p t a b i l i t y   i s   b r o k e n   i n   X c o d e   4 . 1 . �  � � � O   ~� � � � k   �� � �  � � � Q   � � � � � � Z   � � � ��� � � =  � � � � � o   � ����� 0 projectpath projectPath � m   � � � � � � �  C U R R E N T _ P R O J E C T � r   � � � � � 4   � ��� �
�� 
proj � m   � �����  � o      ���� 0 
theproject 
theProject��   � r   � � � � � I  � ��� ���
�� .aevtodocnull  �    alis � l  � � ����� � c   � � � � � 4   � ��� �
�� 
psxf � o   � ����� 0 projectpath projectPath � m   � ���
�� 
alis��  ��  ��   � o      ���� 0 
theproject 
theProject � R      ������
�� .ascrerr ****      � ****��  ��   � L   � � � � b   � � � � � m   � � � � � � � . C o u l d   n o t   o p e n   p r o j e c t   � o   � ����� 0 projectpath projectPath �  � � � l  � ���������  ��  ��   �  � � � r   � � � � � n   � � � � � 1   � ���
�� 
pnam � o   � ����� 0 
theproject 
theProject � o      ���� 0 projectname projectName �  � � � l  � ���������  ��  ��   �  � � � r   � � � � � m   � ���
�� 
msng � o      ���� 0 	thetarget 	theTarget �  � � � X   � ��� � � k   � � �  � � � I  � ��� ���
�� .ascrcmnt****      � **** � l  � � ����� � c   � � � � � l  � � ����� � n   � � � � � 1   � ���
�� 
pnam � o   � ����� 0 atarget aTarget��  ��   � m   � ���
�� 
TEXT��  ��  ��   �  ��� � Z   � � ����� � =  � � � � l  � ����� � c   � � � � l  � ����� � n   �   1   ���
�� 
pnam o   � ����� 0 atarget aTarget��  ��   � m  ��
�� 
TEXT��  ��   � o  ���� 0 
targetname 
targetName � r  
 o  
���� 0 atarget aTarget o      �� 0 	thetarget 	theTarget��  ��  ��  �� 0 atarget aTarget � n   � � 2  � ��~
�~ 
tarR o   � ��}�} 0 
theproject 
theProject �  l �|�{�z�|  �{  �z   	 r  $

 n    2  �y
�y 
bucf o  �x�x 0 	thetarget 	theTarget o      �w�w (0 targetbuildconfigs targetBuildConfigs	  l %%�v�u�t�v  �u  �t    Q  %w r  (0 n  (, 4  ),�s
�s 
cobj m  *+�r�r  o  ()�q�q 0 args   o      �p�p $0 newversionstring newVersionString R      �o�n�m
�o .ascrerr ****      � ****�n  �m   k  8w  r  8O n  8K  l @K!�l�k! n  @K"#" 1  GK�j
�j 
valL# l @G$�i�h$ 4  @G�g%
�g 
asbs% m  CF&& �'' . C U R R E N T _ P R O J E C T _ V E R S I O N�i  �h  �l  �k    n  8@()( 4  ;@�f*
�f 
bucf* m  >?�e�e ) o  8;�d�d 0 	thetarget 	theTarget o      �c�c  0 currentversion currentVersion +,+ I Pk�b-.
�b .panSdlognull���    obj - b  Pa/0/ b  P]121 b  PY343 b  PU565 m  PS77 �88 J P l e a s e   e n t e r   n e w   v e r s i o n   f o r   t a r g e t   "6 o  ST�a�a 0 
targetname 
targetName4 m  UX99 �::  "   i n   p r o j e c t   "2 o  Y\�`�` 0 projectname projectName0 m  ]`;; �<< > " .     ( C u r r e n t   v e r s i o n   i s   s h o w n . ). �_=�^
�_ 
dtxt= o  dg�]�]  0 currentversion currentVersion�^  , >�\> r  lw?@? n  lsABA 1  os�[
�[ 
ttxtB 1  lo�Z
�Z 
rslt@ o      �Y�Y $0 newversionstring newVersionString�\   CDC l xx�X�W�V�X  �W  �V  D EFE l xx�UGH�U  G U O Overwrite CURRENT_PROJECT_VERSION at Target Layer for all build configurations   H �II �   O v e r w r i t e   C U R R E N T _ P R O J E C T _ V E R S I O N   a t   T a r g e t   L a y e r   f o r   a l l   b u i l d   c o n f i g u r a t i o n sF J�TJ X  x�K�SLK O  ��MNM r  ��OPO o  ���R�R $0 newversionstring newVersionStringP l     Q�Q�PQ n      RSR 1  ���O
�O 
valLS l ��T�N�MT 4  ���LU
�L 
asbsU m  ��VV �WW . C U R R E N T _ P R O J E C T _ V E R S I O N�N  �M  �Q  �P  N o  ���K�K *0 aprojectbuildconfig aProjectBuildConfig�S *0 aprojectbuildconfig aProjectBuildConfigL o  {~�J�J (0 targetbuildconfigs targetBuildConfigs�T   � 4   ~ ��IX
�I 
cappX m   � �YY �ZZ D / D e v e l o p e r 3 / A p p l i c a t i o n s / X c o d e . a p p � [\[ l ���H�G�F�H  �G  �F  \ ]�E] L  ��^^ b  ��_`_ b  ��aba b  ��cdc b  ��efe b  ��ghg b  ��iji m  ��kk �ll F D i d   s e t   C U R R E N T _ P R O J E C T _ V E R S I O N   t o  j o  ���D�D $0 newversionstring newVersionStringh m  ��mm �nn    i n   t a r g e t  f o  ���C�C 0 
targetname 
targetNamed m  ��oo �pp    i n   p r o j e c t  b o  ���B�B 0 projectname projectName` m  ��qq �rr~ .   
 	 
 	 N o t e   t h a t   t h i s   w i l l   o n l y   a p p e a r   i n   y o u r   n e x t   b u i l d   a s   e x p e c t e d   i f   ( a )   t h e   I n f o . p l i s t   p r o d u c t s   i n   y o u r   p r o j e c t   u s e   t h e   p l a c e h o l d e r   $ { C U R R E N T _ P R O J E C T _ V E R S I O N }   i n s t e a d   o f   h a r d   c o d i n g   t h e   v e r s i o n   ( u s u a l l y   i n   3   k e y / v a l u e s ) ,   ( b )   a n y   t a r g e t   i n   t h e   p r o j e c t   w i t h   a n   I n f o . p l i s t   h a s   t h e   I n f o . p l i s t   P r e p r o c e s s i n g   B u i l d   S e t t i n g   s w i t c h e d   O N   a n d   ( c )   a n y   t a r g e t   i n   t h e   p r o j e c t   w i t h   a n   I n f o . p l i s t   h a s   a   " T o u c h   I n f o . p l i s t "   B u i l d   P h a s e ,   t o   f o r c e   X c o d e   t o   a l w a y s   p r e p r o c e s s   a n d   c r e a t e   a   n e w   I n f o . p l i s t   w i t h   e a c h   b u i l d        T h e   l a s t   r e q u i r e m e n t   i s   d u e   t o   A p p l e   B u g   5 6 2 4 9 5 4 ,   D u p l i c a t e / 4 5 0 5 1 4 1 .�E    sts l     �A�@�?�A  �@  �?  t u�>u l     �=�<�;�=  �<  �;  �>       �:v�9wxyz{|}~�8�7�6�5�4�3�2�:  v �1�0�/�.�-�,�+�*�)�(�'�&�%�$�#�"�1 0 isdebugging isDebugging
�0 .aevtoappnull  �   � ****�/ 0 args  �. 0 
targetname 
targetName�- 0 projectname projectName�, 0 
theproject 
theProject�+ 0 	thetarget 	theTarget�* (0 targetbuildconfigs targetBuildConfigs�) $0 newversionstring newVersionString�(  �'  �&  �%  �$  �#  �"  
�9 boovfalsw �! � ���
�! .aevtoappnull  �   � ****�  0 argv  �   ����� 0 argv  � 0 projectpath projectPath� 0 atarget aTarget� *0 aprojectbuildconfig aProjectBuildConfig� 9� / < I a�� f k����� � ���� ���Y ����
�	� ��������� ��������&����79;��������Vkmoq� 0 args  
� 
ret 
� 
cobj
� .sysodlogaskr        TEXT� 0 
targetname 
targetName�  �  � 0 
scriptname 
scriptName� 0 msg  
� 
errn�   �1� 0 projectname projectName
� 
capp
� 
proj� 0 
theproject 
theProject
�
 
psxf
�	 
alis
� .aevtodocnull  �    alis
� 
pnam
� 
msng� 0 	thetarget 	theTarget
� 
tarR
� 
kocl
� .corecnte****       ****
� 
TEXT
�  .ascrcmnt****      � ****
�� 
bucf�� (0 targetbuildconfigs targetBuildConfigs�� $0 newversionstring newVersionString
�� 
asbs
�� 
valL��  0 currentversion currentVersion
�� 
dtxt
�� .panSdlognull���    obj 
�� 
rslt
�� 
ttxt��b   e  9jvE�O��6FO��6FO��6FO��%�%��k/%�%�%�%��l/%�%��m/%j 	Y �E�O ��k/E�O��l/E�W X  ��%�%�%E` O)a a l_ Oa E` O)a a / ,�a   *a k/E` Y *a �/a &j E` W X  a �%O_ a ,E` Oa E`  O A_ a !-[a "�l #kh �a ,a $&j %O�a ,a $&�  
�E`  Y h[OY��O_  a &-E` 'O ��m/E` (W FX  _  a &k/a )a */a +,E` ,Oa -�%a .%_ %a /%a 0_ ,l 1O_ 2a 3,E` (O -_ '[a "�l #kh � _ (*a )a 4/a +,FU[OY��UOa 5_ (%a 6%�%a 7%_ %a 8%x ����� �  �y~� ��� � / U s e r s / j k / D o c u m e n t s / P r o g r a m m i n g / P r o j e c t s / B o o k M a c s t e r / B o o k M a c s t e r . x c o d e p r o jy ���  M a i n A p p - O S X 5~ ���  1 . 6 . 1 1z ��� * B o o k M a c s t e r . x c o d e p r o j{ �� ������                                                                                  xcde  alis    ^  
MacMini2-1                 ���H+   
��	Xcode.app                                                       
���f�        ����  	                Applications    ��Yr      �g2r     
�� 
ľ  .MacMini2-1:Developer3: Applications: Xcode.app   	 X c o d e . a p p   
 M a c M i n i 2 - 1  !Developer3/Applications/Xcode.app   / ��  
�� 
prdc� ��� * B o o k M a c s t e r . x c o d e p r o j| �� ������ {��
�� 
tarR
�� 
cobj�� } ����� �  ��� �� ������� ������� ����
�� 
proj� ���  B o o k M a c s t e r
�� 
tarR� ��� 0 4 8 9 D 1 7 9 2 1 4 0 E C 5 7 7 0 0 F 2 4 5 2 F
�� kfrmID  
�� 
bucf� ��� 0 4 8 9 D 1 8 2 9 1 4 0 E C 5 7 7 0 0 F 2 4 5 2 F
�� kfrmID  � �� ������� ������� ����
�� 
proj� ���  B o o k M a c s t e r
�� 
tarR� ��� 0 4 8 9 D 1 7 9 2 1 4 0 E C 5 7 7 0 0 F 2 4 5 2 F
�� kfrmID  
�� 
bucf� ��� 0 4 8 9 D 1 8 2 A 1 4 0 E C 5 7 7 0 0 F 2 4 5 2 F
�� kfrmID  �8  �7  �6  �5  �4  �3  �2   ascr  ��ޭ