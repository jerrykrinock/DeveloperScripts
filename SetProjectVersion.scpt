FasdUAS 1.101.10   ��   ��    k             l        	  j     �� 
�� 0 isdebugging isDebugging 
 m     ��
�� boovtrue    make true for debugging    	 �   0   m a k e   t r u e   f o r   d e b u g g i n g      l     ��������  ��  ��        i        I     �� ��
�� .aevtoappnull  �   � ****  o      ���� 0 argv  ��    k    �       I    ��  
�� .sysodlogaskr        TEXT  m        �   � S o r r y ,   t h i s   s c r i p t   w i l l   n o t   w o r k   i n   X c o d e   4   u n t i l   A p p l e   f i x e s   X c o d e ' s   A p p l e S c r i p t a b i l i t y  ��  
�� 
btns  J        ��  m       �    Q u i t��    ��  ��
�� 
dflt   m     ! ! � " "  Q u i t��     # $ # L    ����   $  % & % l   ��������  ��  ��   &  ' ( ' Z    G ) *�� + ) l    ,���� , =    - . - o    ���� 0 isdebugging isDebugging . m    ��
�� boovtrue��  ��   * k    A / /  0 1 0 l   �� 2 3��   2 X R Debugging Section.  Use these test arguments to test this script in Script Editor    3 � 4 4 �   D e b u g g i n g   S e c t i o n .     U s e   t h e s e   t e s t   a r g u m e n t s   t o   t e s t   t h i s   s c r i p t   i n   S c r i p t   E d i t o r 1  5 6 5 r     7 8 7 J    ����   8 o      ���� 0 args   6  9 : 9 l   �� ; <��   ;   Path to .xcodeproj:    < � = = (   P a t h   t o   . x c o d e p r o j : :  > ? > r    " @ A @ m     B B � C C � / U s e r s / j k / D o c u m e n t s / P r o g r a m m i n g / P r o j e c t s / B o o k M a c s t e r / B o o k M a c s t e r . x c o d e p r o j A n       D E D  ;     ! E o     ���� 0 args   ?  F G F l  # #�� H I��   H   New version string:    I � J J (   N e w   v e r s i o n   s t r i n g : G  K L K r   # ' M N M m   # $ O O � P P  1 . 1 2 . 2 N n       Q R Q  ;   % & R o   $ %���� 0 args   L  S�� S I  ( A�� T��
�� .sysodlogaskr        TEXT T b   ( = U V U b   ( 8 W X W b   ( 6 Y Z Y b   ( 4 [ \ [ b   ( 2 ] ^ ] b   ( - _ ` _ b   ( + a b a m   ( ) c c � d d � W A R N I N G .     S e t P r o j e c t V e r s i o n   i s   u s i n g   h a r d - c o d e d   D e b u g   T e s t   p a r a m e t e r s .     W i l l   s e t :   b o   ) *��
�� 
ret  ` o   + ,��
�� 
ret  ^ n   - 1 e f e 4   . 1�� g
�� 
cobj g m   / 0����  f o   - .���� 0 args   \ o   2 3��
�� 
ret  Z o   4 5��
�� 
ret  X m   6 7 h h � i i    t o   v e r s i o n   V n   8 < j k j 4   9 <�� l
�� 
cobj l m   : ;����  k o   8 9���� 0 args  ��  ��  ��   + r   D G m n m o   D E���� 0 argv   n o      ���� 0 args   (  o p o l  H H��������  ��  ��   p  q r q l  H H�� s t��   s   Get arguments    t � u u    G e t   a r g u m e n t s r  v w v q   H H x x ������ 0 projectpath projectPath��   w  y z y Q   H y { | } { r   K Q ~  ~ n   K O � � � 4   L O�� �
�� 
cobj � m   M N����  � o   K L���� 0 args    o      ���� 0 projectpath projectPath | R      ������
�� .ascrerr ****      � ****��  ��   } k   Y y � �  � � � r   Y l � � � b   Y h � � � b   Y d � � � b   Y ` � � � o   Y \���� 0 
scriptname 
scriptName � m   \ _ � � � � �. :   E r r o r :   i n v a l i d   a r g u m e n t s .     T h i s   s c r i p t   w i l l   b u i l d   a l l   c o n f i g u r a t i o n s   o f   a   d e s i g n a t e d   X c o d e   p r o j e c t   +   t a r g e t .  U s a g e   i s :              o s a s c r i p t   p o s i x / p a t h / t o / � o   ` c���� 0 
scriptname 
scriptName � m   d g � � � � �� . s c p t   p r o j e c t   v e r s i o n                    w h e r e 
           p r o j e c t   m a y   b e   e i t h e r   t h e   c o n s t a n t   C U R R E N T _ P R O J E C T   t o   i n d i c a t e   t h e   f r o n t m o s t   p r o j e c t ,   o r   a   f u l l   p a t h   t o   a n   X c o d e   p r o j e c t   f i l e ,   s u c h   a s   / f u l l / p a t h / t o / M y P r o j e c t . x c o d e p r o j                    v e r s i o n   i s   t h e   o p t i o n a l   n e w   v e r s i o n   s t r i n g   w h i c h   w i l l   b e   s e t   a t   t h e   p r o j e c t   l a y e r .     E x a m p l e :   " 1 . 0 . 0 " .     I f   n o t   g i v e n ,   a   d i a l o g   w i l l   a s k . � o      ���� 0 msg   �  � � � l  m m�� � ���   � * $ The following will abort the script    � � � � H   T h e   f o l l o w i n g   w i l l   a b o r t   t h e   s c r i p t �  ��� � R   m y�� � �
�� .ascrerr ****      � **** � o   u x���� 0 msg   � �� ���
�� 
errn � m   q t����   �1��  ��   z  � � � r   z � � � � m   z } � � � � �  N O - P R O J E C T ! ! � o      ���� 0 projectname projectName �  � � � l  � ���������  ��  ��   �  � � � O   �p � � � k   �o � �  � � � Q   � � � � � � Z   � � � ��� � � =  � � � � � o   � ����� 0 projectpath projectPath � m   � � � � � � �  C U R R E N T _ P R O J E C T � r   � � � � � 4   � ��� �
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
theProject � o      ���� 0 projectname projectName �  � � � l  � ���������  ��  ��   �  � � � Q   � � � � � r   � � � � � n   � � � � � 4   � ��� �
�� 
cobj � m   � �����  � o   � ����� 0 args   � o      ���� $0 newversionstring newVersionString � R      ������
�� .ascrerr ****      � ****��  ��   � k   � � �  � � � r   � � � � � n   � � � � � l  � � ����� � n   � � � � � 1   � ���
�� 
valL � l  � � ����� � 4   � ��� �
�� 
asbs � m   � � � � � � � . C U R R E N T _ P R O J E C T _ V E R S I O N��  ��  ��  ��   � n   � � � � � 4   � ��� �
�� 
tarR � m   � �����  � o   � ����� 0 
theproject 
theProject � o      ����  0 currentversion currentVersion �  � � � I  ��� � �
�� .sysodlogaskr        TEXT � b   � � � � b   � � � � � m   � � � � � � � L P l e a s e   e n t e r   n e w   v e r s i o n   f o r   p r o j e c t   " � o   � ����� 0 projectname projectName � m   � � � � � � > " .     ( C u r r e n t   v e r s i o n   i s   s h o w n . ) � �� ���
�� 
dtxt � o  	����  0 currentversion currentVersion��   �  ��� � r   � � � n   � � � 1  ��
�� 
ttxt � 1  ��
�� 
rslt � o      ���� $0 newversionstring newVersionString��   �  � � � l ��������  ��  ��   �  � � � l �� � ���   � V P Overwrite CURRENT_PROJECT_VERSION at Project Layer for all build configurations    � �   �   O v e r w r i t e   C U R R E N T _ P R O J E C T _ V E R S I O N   a t   P r o j e c t   L a y e r   f o r   a l l   b u i l d   c o n f i g u r a t i o n s �  O  m k   l  r   )	 1   %�
� 
pnam	 o      �~�~ 0 np nP 

 I *5�}�|
�} .ascrcmnt****      � **** l *1�{�z b  *1 m  *- �  p r o j e c t   n a m e :   o  -0�y�y 0 np nP�{  �z  �|    r  6D n  6@ 2 <@�x
�x 
tarR 4  6<�w
�w 
proj m  :;�v�v  o      �u�u 0 alltars allTars  I ET�t�s
�t .ascrcmnt****      � **** l EP�r�q b  EP m  EH �    c o u n t :   l HO!�p�o! I HO�n"�m
�n .corecnte****       ****" o  HK�l�l 0 alltars allTars�m  �p  �o  �r  �q  �s   #$# r  U`%&% n  U\'(' 1  X\�k
�k 
pnam( o  UX�j�j 0 t1  & o      �i�i 0 n1  $ )�h) I al�g*�f
�g .ascrcmnt****      � ***** l ah+�e�d+ b  ah,-, m  ad.. �//  t a r g e t   1   i s  - o  dg�c�c 0 t1  �e  �d  �f  �h   o  �b�b 0 
theproject 
theProject 0�a0 l nn�`�_�^�`  �_  �^  �a   � m   � �11�                                                                                      @ alis    6  Air1HD                     ���PH+   B(�	Xcode.app                                                       i�3�C3�        ����  	                Applications    ��G�      �C�O     B(�  Air1HD:Applications: Xcode.app   	 X c o d e . a p p    A i r 1 H D  Applications/Xcode.app  / ��   � 232 l qq�]�\�[�]  �\  �[  3 4�Z4 L  q�55 b  q�676 b  q�898 b  q|:;: b  qx<=< m  qt>> �?? F D i d   s e t   C U R R E N T _ P R O J E C T _ V E R S I O N   t o  = o  tw�Y�Y $0 newversionstring newVersionString; m  x{@@ �AA    i n   p r o j e c t  9 o  |�X�X 0 projectname projectName7 m  ��BB �CC@ .   
 	 
 	 T h i s   w i l l   o n l y   w o r k   a s   e x p e c t e d   i f   ( a )   t h e   I n f o . p l i s t   p r o d u c t s   i n   y o u r   p r o j e c t   u s e   t h e   p l a c e h o l d e r   $ { C U R R E N T _ P R O J E C T _ V E R S I O N }   i n s t e a d   o f   h a r d   c o d i n g   t h e   v e r s i o n   ( u s u a l l y   i n   3   k e y / v a l u e s ) ,   ( b )   a n y   t a r g e t   i n   t h e   p r o j e c t   w i t h   a n   I n f o . p l i s t   h a s   t h e   I n f o . p l i s t   P r e p r o c e s s i n g   B u i l d   S e t t i n g   s w i t c h e d   O N   a n d   ( c )   a n y   t a r g e t   i n   t h e   p r o j e c t   w i t h   a n   I n f o . p l i s t   h a s   a   " T o u c h   I n f o . p l i s t "   B u i l d   P h a s e ,   t o   f o r c e   X c o d e   t o   a l w a y s   p r e p r o c e s s   a n d   c r e a t e   a   n e w   I n f o . p l i s t   w i t h   e a c h   b u i l d        T h e   l a s t   r e q u i r e m e n t   i s   d u e   t o   A p p l e   B u g   5 6 2 4 9 5 4 ,   D u p l i c a t e / 4 5 0 5 1 4 1 .�Z    DED l     �W�V�U�W  �V  �U  E F�TF l     �S�R�Q�S  �R  �Q  �T       �PG�OH�P  G �N�M�N 0 isdebugging isDebugging
�M .aevtoappnull  �   � ****
�O boovtrueH �L �K�JIJ�I
�L .aevtoappnull  �   � ****�K 0 argv  �J  I �H�G�H 0 argv  �G 0 projectpath projectPathJ 8 �F �E !�D�C�B B O c�A�@ h�?�>�= � ��<�;�: ��91 ��8�7�6�5�4 ��3�2�1�0 ��/�. � ��-�,�+�*�)�(�'�&�%.>@B
�F 
btns
�E 
dflt�D 
�C .sysodlogaskr        TEXT�B 0 args  
�A 
ret 
�@ 
cobj�?  �>  �= 0 
scriptname 
scriptName�< 0 msg  
�; 
errn�:   �1�9 0 projectname projectName
�8 
proj�7 0 
theproject 
theProject
�6 
psxf
�5 
alis
�4 .aevtodocnull  �    alis
�3 
pnam�2 $0 newversionstring newVersionString
�1 
tarR
�0 
asbs
�/ 
valL�.  0 currentversion currentVersion
�- 
dtxt
�, 
rslt
�+ 
ttxt�* 0 np nP
�) .ascrcmnt****      � ****�( 0 alltars allTars
�' .corecnte****       ****�& 0 t1  �% 0 n1  �I����kv��� OhOb   e  -jvE�O��6FO��6FO��%�%��k/%�%�%�%��l/%j Y �E�O ��k/E�W 'X  _ a %_ %a %E` O)a a l_ Oa E` Oa  � ,�a   *a k/E` Y *a �/a &j E` W X  a �%O_ a  ,E` O ��l/E` !W @X  _ a "k/a #a $/a %,E` &Oa '_ %a (%a )_ &l O_ *a +,E` !O_  N*a  ,E` ,Oa -_ ,%j .O*a k/a "-E` /Oa 0_ /j 1%j .O_ 2a  ,E` 3Oa 4_ 2%j .UOPUOa 5_ !%a 6%_ %a 7%ascr  ��ޭ