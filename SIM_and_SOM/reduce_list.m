used = [0269,0378,0067,0304,0072,0309,0351,0349,0109,0385,0501,0155,0170,0325,0173,0199,0315,0097,0123,0154,0131,0035,0087,0184,0218,...
    0244,0147,0144,0096,0143,0008,0407,0497,0439,0328,0426,0105,0086,0146,0324,0102,0284,0386,0329,0371,0364,0020,0080,0296,0318,0432,...
    0016,0114,0422,0367,0333,0401,0323,0113,0404,0236,0115,0442,0078,0311,0281,0165,0393,0007,0137,0141,0237,0193,0247,0254,0118,0300,...
    0134,0042,0233,0125,0226,0002,0382,0489,0505,0398,0486,0019,0265,0337,0417,0387,0412,0030,0026,0130,0424,0262,0090,0264,0481,0470,...
    0339,0050,0252,0272,0083,0238,0306,0093,0043,0433,0168,0070,0175,0038,0182];

init = 0;
for i=1:1:505
    was_used = 0;
    for j=1:1:size(used,2)
       if(i == used(j) )
          was_used = 1; 
       end
    end
    
    if(was_used == 0)
       if (init == 0)
          not_used = i; 
           init = 1;
       else
           not_used = [not_used i];
       end
    end
end