%% RETO 3 - PASO 2: CONTROL DE LA MICRO-RED (SIGE)
%% Estudiante: Juan Camilo Hincapié Fernández
%% Curso: Software para Ingeniería

% Limpiar la consola y borrar variables guardadas
clc;
clear;
close all;
 
%% 1. CONFIGURACIÓN INICIAL
 
% Generación solar: empieza en 0 todas las horas
solar = zeros(1, 24);
 
% Subida del sol: horas 6 a 12 (el pico es 25 kW en la hora 12)
for h = 6:12
    solar(h) = 25 * (h - 5) / 7;
end
 
% Bajada del sol: horas 13 a 18
for h = 13:18
    solar(h) = 25 * (19 - h) / 7;
end
 
% Generación eólica (24 valores, máximo 15 kW)
eolica = [ 6  8  5  9 12  7 10 13  8 11 ...
          14  9 12 10 13  7 11  8 12 14 ...
           9 10  6  8];
 
generacion_total = solar + eolica;
 
% Demanda de la comunidad (24 valores)
demanda = zeros(1, 24);
demanda([1:5, 22:24]) = [2.0 2.4 2.1 3.2 3.7 3.8 3.4 2.8];
demanda(6:17)  = [6 6.5 7 7.5 8 8.5 9 9.5 10 9 8 7];
demanda(18:21) = [12 14 15 13];
 
% Datos de la batería
capacidad = 100;    
SOC = 50;           

%% 2. TÍTULO DEL REPORTE
 
disp('===== REPORTE POR HORA DEL SIGE =====');
disp(' ');
 
%% 3. BUCLE DE 24 HORAS
 
for h = 1:24
 
    % Tomamos la generación y la demanda de esta hora
    Egen = generacion_total(h);
    Edem = demanda(h);
 
    % Variables para guardar el estado de cada servicio
    escuela = 'ACTIVA';
    bombeo = 'ACTIVO';
    alumbrado = 'ACTIVO';
 
    % Comparamos lo que se genera con lo que se consume
    if Egen >= Edem
 
        % --- SUPERÁVIT: sobra energía ---
        excedente = Egen - Edem;
        balance = excedente;
        SOC = SOC + (excedente / capacidad) * 100;
 
        % La batería no puede pasar de 100%
        if SOC > 100
            SOC = 100;
        end
 
    else
 
        % --- DÉFICIT: falta energía ---
        faltante = Edem - Egen;
        balance = -faltante;
        SOC = SOC - (faltante / capacidad) * 100;
 
        % La batería no puede bajar de 0%
        if SOC < 0
            SOC = 0;
        end
 
        % Revisamos el SOC para decidir qué apagar
        if SOC > 40
            % RUTA SEGURA: no se apaga nada
 
        elseif SOC > 20
            % RUTA DE ALERTA: se apaga el alumbrado
            alumbrado = 'SUSPENDIDO';
 
        else
            % RUTA DE EMERGENCIA: se apaga alumbrado y bombeo
            alumbrado = 'SUSPENDIDO';
            bombeo = 'SUSPENDIDO';
        end
 
    end
 
    % Guardamos el SOC de esta hora para poder graficarlo al final
    SOC_hora(h) = SOC;
    balance_hora(h) = balance;    % Guardamos también el balance de esta hora
 
    % Mostramos el reporte de esta hora
    fprintf('Hora %d\n', h);
    fprintf('  Generación: %.2f kWh | Demanda: %.2f kWh\n', Egen, Edem);
    fprintf('  Balance de energía: %.2f kWh\n', balance);
    fprintf('  SOC de la batería: %.2f %%\n', SOC);
    fprintf('  Escuela: %s | Bombeo: %s | Alumbrado: %s\n', escuela, bombeo, alumbrado);
    disp(' ');
 
end
 
disp('===== FIN DE LA SIMULACIÓN =====');
 
%% 4. GRÁFICAS
 
% --- Gráfica 1: Generación total vs Demanda ---
figure(1);
plot(1:24, generacion_total, 'g-o', 'LineWidth', 2);
hold on;
plot(1:24, demanda, 'r-s', 'LineWidth', 2);
title('Generación total vs Demanda');
xlabel('Tiempo (horas)');
ylabel('Potencia (kW)');
legend('Generación total', 'Demanda');
grid on;
xlim([1 24]);
hold off;
 
% --- Gráfica 2: Estado de carga (SOC) ---
figure(2);
 
plot(1:24, SOC_hora, 'b-o', 'LineWidth', 2);
hold on;
plot([1 24], [40 40], 'g--');
plot([1 24], [20 20], 'r--');
title('Estado de carga (SOC) de la batería');
xlabel('Tiempo (horas)');
ylabel('SOC (%)');
legend('SOC', 'Umbral 40%', 'Umbral 20%');
grid on;
ylim([0 100]);
xlim([1 24]);
hold off;