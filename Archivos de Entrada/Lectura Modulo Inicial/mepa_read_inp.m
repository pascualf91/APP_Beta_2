function d = mepa_read_inp(path)
    f = fopen(path);
    lines = textscan(f, '%s', 'delimiter', '\n');

    lines = lines{1};
    n = length(lines);

    expect_section_name = true;
    d = struct;

    % preprocess; drop empty lines and comments
    preprocessed_lines = {};
    for i = 1:n
        l = lines{i};
        
        % skip empty lines
        if isempty(l)
            continue;
        end

        % locate comment (;)
        l = textscan(l, '%s', 'delimiter', ';');
        l = l{1}{1};

        if isempty(l)
            continue;
        end

        preprocessed_lines{end+1} = l;
    end

    preprocessed_lines{end+1} = '42'; % otherwise we lose last section
    n = length(preprocessed_lines);
    i = 1;

    % actual parsing
    while i <= n
        l = preprocessed_lines{i};

        % parse section name
        if expect_section_name
            if l(1) == '['
                l = textscan(l, '%s', 'delimiter', ']');
                l = l{1}{1};
                name = l(2:end);
                data = {};
                x = 0; y = 0;
                expect_section_name = false;
                d.(name) = {};
            end
        % parse data lines
        else
            if l(1) == '[' || i == n
                expect_section_name = true;
                i = i - 1;
                d.(name) = data;
            else
                x = x + 1;
                z = textscan(l, '%s');
                z = z{1};
                len = length(z);
                for j = 1:len
                    y = y + 1;
                    data{x,y} = z{j};
                end
                y = 0;
            end
        end

        i = i + 1;
    end

    fclose(f);
end
