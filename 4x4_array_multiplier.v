//==============================================================
// 4x4 Array Multiplier - Fully Flattened to Gate Primitives
//==============================================================
module ved4b (
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       clk,
  output reg  [7:0] P
);

  // -------- Partial products --------
  wire z0, z1, z2, z3;
  wire z4, z5, z6, z7;
  wire z8, z9, z10, z11;
  wire z12, z13, z14, z15;

  and (z0,  a[0], b[0]);
  and (z1,  a[0], b[1]);
  and (z2,  a[0], b[2]);
  and (z3,  a[0], b[3]);

  and (z4,  a[1], b[0]);
  and (z5,  a[1], b[1]);
  and (z6,  a[1], b[2]);
  and (z7,  a[1], b[3]);

  and (z8,  a[2], b[0]);
  and (z9,  a[2], b[1]);
  and (z10, a[2], b[2]);
  and (z11, a[2], b[3]);

  and (z12, a[3], b[0]);
  and (z13, a[3], b[1]);
  and (z14, a[3], b[2]);
  and (z15, a[3], b[3]);

  // -------- Column 0 --------
  wire p0 = z0;

  // -------- Column 1 (HA: z4, z1) --------
  wire p1, c1;
  xor (p1, z4, z1);
  and (c1, z4, z1);

  // -------- Column 2 (FA: z8, z5, z2) + c1 --------
  wire s2a, c2a1, c2a2, c2a;
  xor (s2a, z8, z5);
  and (c2a1, z8, z5);
  wire s2b;
  xor (s2b, s2a, z2);
  and (c2a2, s2a, z2);
  or  (c2a, c2a1, c2a2);

  wire p2, c2b;
  xor (p2, s2b, c1);
  and (c2b, s2b, c1);

  // -------- Column 3 --------
  // FA1: z12, z9, z6
  wire s3a, c3a1, c3a2, c3a;
  xor (s3a, z12, z9);
  and (c3a1, z12, z9);
  wire s3b;
  xor (s3b, s3a, z6);
  and (c3a2, s3a, z6);
  or  (c3a, c3a1, c3a2);

  // FA2: s3b, z3, c2a
  wire s3c, c3b1, c3b2, c3b;
  xor (s3c, s3b, z3);
  and (c3b1, s3b, z3);
  wire s3d;
  xor (s3d, s3c, c2a);
  and (c3b2, s3c, c2a);
  or  (c3b, c3b1, c3b2);

  // HA: s3d, c2b
  wire p3, c3c;
  xor (p3, s3d, c2b);
  and (c3c, s3d, c2b);

  // -------- Column 4 --------
  // FA1: z13, z10, z7
  wire s4a, c4a1, c4a2, c4a;
  xor (s4a, z13, z10);
  and (c4a1, z13, z10);
  wire s4b;
  xor (s4b, s4a, z7);
  and (c4a2, s4a, z7);
  or  (c4a, c4a1, c4a2);

  // FA2: s4b, c3a, c3b
  wire s4c, c4b1, c4b2, c4b;
  xor (s4c, s4b, c3a);
  and (c4b1, s4b, c3a);
  wire s4d;
  xor (s4d, s4c, c3b);
  and (c4b2, s4c, c3b);
  or  (c4b, c4b1, c4b2);

  // HA: s4d, c3c
  wire p4, c4c;
  xor (p4, s4d, c3c);
  and (c4c, s4d, c3c);

  // -------- Column 5 --------
  // FA1: z14, z11, c4a
  wire s5a, c5a1, c5a2, c5a;
  xor (s5a, z14, z11);
  and (c5a1, z14, z11);
  wire s5b;
  xor (s5b, s5a, c4a);
  and (c5a2, s5a, c4a);
  or  (c5a, c5a1, c5a2);

  // FA2: s5b, c4b, c4c
  wire p5, c5b1, c5b2, c5b;
  xor (p5, s5b, c4b);
  and (c5b1, s5b, c4b);
  wire s5c;
  xor (s5c, p5, c4c); // reuse p5 as intermediate sum here
  and (c5b2, p5, c4c);
  or  (c5b, c5b1, c5b2);

  // -------- Column 6 --------
  // FA: z15, c5a, c5b
  wire p6, c6a1, c6a2, p7;
  xor (p6, z15, c5a);
  and (c6a1, z15, c5a);
  wire s6b;
  xor (s6b, p6, c5b);
  and (c6a2, p6, c5b);
  or  (p7, c6a1, c6a2); // p7 is final carry

  // -------- Register outputs --------
  wire [7:0] p_comb = {p7, s6b, s5c, p4, p3, p2, p1, p0};

  always @(posedge clk) begin
    P <= p_comb;
  end

endmodule
