function dist = distP2S(x, a, b)
% 计算点到段之间的最小距离
    d_ab = norm(a-b);
    d_ax = norm(a-x);
    d_bx = norm(b-x);
    p = (d_ab + d_ax + d_bx) / 2;
    if d_ab ~= 0
        if dot(a-b, x-b) * dot(b-a, x-a) >= 0
            S = sqrt(p * (p - d_ab) * (p - d_ax) * (p - d_bx));
            dist = 2 * S / d_ab; % 点线距离公式
        else
            dist = min(d_ax, d_bx);
        end
    else % 如果a和b相等
        dist = d_ax;
    end
end