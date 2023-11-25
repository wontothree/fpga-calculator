module InfixToPostfixAndEvaluate (
    input [31:0] infix_expression [0:99],
    input [31:0] infix_length,
    output [31:0] postfix_result
);
    
    reg [31:0] que_inf [0:99];
    reg [31:0] stk_inf2prf [0:99];
    reg [31:0] que_prf [0:99];
    reg [31:0] stk_prf2rlt [0:99];
    reg [31:0] stk_operator;
    integer que_inf_front, que_inf_rear, stk_inf2prf_top, que_prf_front, que_prf_rear, stk_prf2rlt_top;
    
    initial
    begin
        que_inf_front = 0;
        que_inf_rear = 0;
        stk_inf2prf_top = 0;
        que_prf_front = 0;
        que_prf_rear = 0;
        stk_prf2rlt_top = 0;
    end
    
    // 함수 원형 선언
    function [31:0] getOperatorPriority;
    
    // 중위식을 후위식으로 변환하는 함수
    task InfixToPostfix;
        input [31:0] infix_expr;
        integer i;
        integer priority;
        
        begin
            // 중위식을 후위식으로 변환하여 큐에 저장
            for (i = 0; i < infix_length; i = i + 1)
            begin
                if (infix_expr[i] >= 0) // 피연산자인 경우
                    que_inf[que_inf_rear] = infix_expr[i];
                else // 연산자인 경우
                begin
                    while ((stk_inf2prf_top > 0) && (getOperatorPriority(stk_inf2prf[stk_inf2prf_top]) >= getOperatorPriority(infix_expr[i])))
                    begin
                        que_inf_rear = que_inf_rear + 1;
                        que_inf[que_inf_rear] = stk_inf2prf[stk_inf2prf_top];
                        stk_inf2prf_top = stk_inf2prf_top - 1;
                    end
                    stk_inf2prf_top = stk_inf2prf_top + 1;
                    stk_inf2prf[stk_inf2prf_top] = infix_expr[i];
                end
            end
            
            // 스택에 남아있는 연산자를 큐에 이동
            while (stk_inf2prf_top > 0)
            begin
                que_inf_rear = que_inf_rear + 1;
                que_inf[que_inf_rear] = stk_inf2prf[stk_inf2prf_top];
                stk_inf2prf_top = stk_inf2prf_top - 1;
            end
        end
    endtask
    
    // 후위식을 계산하는 함수
    task EvaluatePostfix;
        integer i;
        
        begin
            for (i = 0; i < que_prf_rear; i = i + 1)
            begin
                if (que_prf[i] >= 0) // 피연산자인 경우
                    stk_prf2rlt_top = stk_prf2rlt_top + 1;
                else // 연산자인 경우
                begin
                    case (que_prf[i])
                        '+': stk_prf2rlt[stk_prf2rlt_top - 1] = stk_prf2rlt[stk_prf2rlt_top - 1] + stk_prf2rlt[stk_prf2rlt_top];
                        '-': stk_prf2rlt[stk_prf2rlt_top - 1] = stk_prf2rlt[stk_prf2rlt_top - 1] - stk_prf2rlt[stk_prf2rlt_top];
                        '*': stk_prf2rlt[stk_prf2rlt_top - 1] = stk_prf2rlt[stk_prf2rlt_top - 1] * stk_prf2rlt[stk_prf2rlt_top];
                        '/': stk_prf2rlt[stk_prf2rlt_top - 1] = stk_prf2rlt[stk_prf2rlt_top - 1] / stk_prf2rlt[stk_prf2rlt_top];
                        // 기타 연산자에 대한 처리 추가
                    endcase
                    stk_prf2rlt_top = stk_prf2rlt_top - 1;
                end
            end
            postfix_result = stk_prf2rlt[0];
        end
    endtask
    
    // 연산자의 우선순위를 반환하는 함수
    function [31:0] getOperatorPriority;
        input [31:0] op;
        
        begin
            case (op)
                '+': return 1;
                '-': return 1;
                '*': return 2;
                '/': return 2;
                // 기타 연산자에 대한 우선순위 추가
                default: return 0;
            endcase
        end
    endfunction
    
    // 모듈 시작
    initial
    begin
        InfixToPostfix(infix_expression);
        // 중위식을 후위식으로 변환하여 que_prf에 저장
        que_prf = que_inf;
        que_prf_front = que_inf_front;
        que_prf_rear = que_inf_rear;
        
        // 후위식을 계산
        EvaluatePostfix();
    end
endmodule
