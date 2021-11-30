function mepa_write_inp(path, d)
    f = fopen(path, 'w');

    section_names = fieldnames(d);
    n = length(section_names);

    for i = 1:n
        name = section_names{i};
        fprintf(f, '[%s]\n', name);
        data = d.(name);
        for k = 1:size(data,1)
            row = data(k,:);
            len = length(find(~cellfun(@isempty,row)));
            fprintf(f, '%s\n', strjoin(row(1:len)));
        end
        fprintf(f, '\n');
    end

    fclose(f);
end

