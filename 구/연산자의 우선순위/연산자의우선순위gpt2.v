module InfixToPostfixEvaluator (
  input wire clk,
  input wire rst,
  input wire [31:0] infix_expression,
  output wire [31:0] result
);

// Operators precedence
parameter ADD_SUB_PRIORITY = 2;
parameter MUL_DIV_PRIORITY = 3;

// Operator stack
reg [31:0] operator_stack [0:99];
reg [7:0] operator_top;

// Output queue
reg [31:0] output_queue [0:99];
reg [7:0] output_top;

// Result stack
reg [31:0] result_stack [0:99];
reg [7:0] result_top;

// Function to push an element to the stack
function push;
  input wire [31:0] element;
  operator_top <= operator_top + 1;
  operator_stack[operator_top] <= element;
endfunction

// Function to pop an element from the stack
function [31:0] pop;
  pop = operator_stack[operator_top];
  operator_top <= operator_top - 1;
endfunction

// Function to push an element to the output queue
function push_output;
  input wire [31:0] element;
  output_top <= output_top + 1;
  output_queue[output_top] <= element;
endfunction

// Function to pop an element from the output queue
function [31:0] pop_output;
  pop_output = output_queue[output_top];
  output_top <= output_top - 1;
endfunction

// Function to push a result to the stack
function push_result;
  input wire [31:0] element;
  result_top <= result_top + 1;
  result_stack[result_top] <= element;
endfunction

// Function to pop a result from the stack
function [31:0] pop_result;
  pop_result = result_stack[result_top];
  result_top <= result_top - 1;
endfunction

// Function to get the precedence of an operator
function [3:0] get_precedence;
  input wire [7:0] operator;
  case (operator)
    '+' : get_precedence = ADD_SUB_PRIORITY;
    '-' : get_precedence = ADD_SUB_PRIORITY;
    '*' : get_precedence = MUL_DIV_PRIORITY;
    '/' : get_precedence = MUL_DIV_PRIORITY;
    default : get_precedence = 0;
  endcase
endfunction

// Function to convert infix expression to postfix expression
function convert_to_postfix;
  input wire [31:0] infix_exp;
  integer i;
  integer infix_length;
  reg [7:0] current_operator;
  reg [3:0] current_operator_precedence;
  reg [3:0] stack_operator_precedence;

  // Initialize
  operator_top <= 0;
  output_top <= 0;

  // Determine the length of the infix expression
  for (i = 0; i < 32; i = i + 1) begin
    if (infix_exp[i] == 0) begin
      infix_length = i;
      break;
    end
  end

  // Process each element in the infix expression
  for (i = 0; i < infix_length; i = i + 1) begin
    if (infix_exp[i] >= '0' && infix_exp[i] <= '9') begin
      // Operand, push to the output queue
      push_output(infix_exp[i]);
    end else begin
      // Operator
      current_operator = infix_exp[i];
      current_operator_precedence = get_precedence(current_operator);

      // Pop operators from the stack and push to the output queue
      // until the stack is empty or the top operator has lower precedence
      while (operator_top > 0) begin
        stack_operator_precedence = get_precedence(operator_stack[operator_top]);
        if (stack_operator_precedence >= current_operator_precedence) begin
          push_output(pop());
        end else begin
          break;
        end
      end

      // Push the current operator to the stack
      push(current_operator);
    end
  end

  // Pop any remaining operators from the stack to the output queue
  while (operator_top > 0) begin
    push_output(pop());
  end
endfunction

// Function to evaluate the postfix expression
function evaluate_postfix;
  input wire [31:0] postfix_exp;
  integer i;
  integer postfix_length;
  reg [31:0] operand1;
  reg [31:0] operand2;

  // Initialize
  result_top <= 0;

  // Determine the length of the postfix expression
  for (i = 0; i < 32; i = i + 1) begin
    if (postfix_exp[i] == 0) begin
      postfix_length = i;
      break;
    end
  end

  // Process each element in the postfix expression
  for (i = 0; i < postfix_length; i = i + 1) begin
    if (postfix_exp[i] >= '0' && postfix_exp[i] <= '9') begin
      // Operand, push to the result stack
      push_result(postfix_exp[i]);
    end else begin
      // Operator
      operand2 = pop_result();
      operand1 = pop_result();
      case (postfix_exp[i])
        '+' : push_result(operand1 + operand2);
        '-' : push_result(operand1 - operand2);
        '*' : push_result(operand1 * operand2);
        '/' : push_result(operand1 / operand2);
      endcase
    end
  end

  // The final result is on the top of the result stack
  result = pop_result();
endfunction

// Main process
always @(posedge clk or posedge rst) begin
  if (rst) begin
    result <= 0;
  end else begin
    // Convert infix to postfix
    convert_to_postfix(infix_expression);

    // Evaluate postfix expression
    evaluate_postfix(output_queue);
  end
end

endmodule
