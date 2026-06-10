#!/usr/bin/env php
<?php

exit(new Application()->run());

class Application
{
    private string $name = 'Import orders by Alexey Tsarkov';

    private array $defaults = [
        'input' => 'php://stdin',
        'output' => 'php://stdout',
    ];

    private PDO $db;

    private SplFileObject $input;

    private SplFileObject $output;

    private SplFileObject $error;

    public function __construct()
    {
        $this->defaults['dsn'] = $_SERVER['DB_DSN'] ?? 'mysql:host=localhost;dbname=sdt';
        $this->defaults['username'] = $_SERVER['DB_USERNAME'] ?? 'sdt';
        $this->defaults['password'] = $_SERVER['DB_PASSWORD'] ?? null;

        $this->error = new SplFileObject('php://stderr', 'w');
    }

    private function configure(): bool
    {
        $options = getopt('ho:d:u:p:', ['help'], $arg);
        if ($options === false || isset($options['h']) || isset($options['help'])) {
            return false;
        }

        $this->input = new SplFileObject($GLOBALS['argv'][$arg] ?? $this->defaults['input']);
        $this->output = new SplFileObject($options['o'] ?? $this->defaults['output'], 'w');

        $this->db = new PDO(
            $options['d'] ?? $this->defaults['dsn'],
            $options['u'] ?? $this->defaults['username'],
            $options['p'] ?? $this->defaults['password'],
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_TIMEOUT => 5,
            ],
        );

        return true;
    }

    public function usage(): string
    {
        extract($this->defaults);
        $script = basename($_SERVER['SCRIPT_FILENAME']);

        return <<<USAGE
            {$this->name}
            Usage: php {$script} [-o out-file] [-d DSN] [-u username] [-p password] [in-file]
              -o out-file  file to log malformed rows (default: {$output})
              -d DSN       PDO data source name (default: {$dsn})
              -u username  database username (default: {$username})
              -p password  database password
              in-file      CSV file to import (defaut: {$input})
            Env:
              DB_DSN, DB_USERNAME, DB_PASSWORD
            USAGE;
    }

    public function run(): int
    {
        try {
            if (!$this->configure()) {
                $this->error->fwrite($this->usage());
                return 1;
            }

            $this->importOrders();
        } catch (Throwable $ex) {
            $this->error->fwrite(get_debug_type($ex) . ': ' . $ex->getMessage() . PHP_EOL);
            return 1;
        }

        return 0;
    }

    private function importOrders(): void
    {
        $stmt = $this->db->prepare('INSERT orders (item_id, customer_id, comment) VALUES (:item_id, :customer_id, :comment)');

        $this->input->setFlags(SplFileObject::SKIP_EMPTY);
        foreach (new NoRewindIterator($this->input) as $line) {
            $order = $this->parseOrder($line);
            if ($order) {
                try {
                    $stmt->bindValue(':item_id', $order[0], PDO::PARAM_INT);
                    $stmt->bindValue(':customer_id', $order[1], PDO::PARAM_INT);
                    $stmt->bindValue(':comment', $order[2]);
                    $stmt->execute();
                    continue;
                } catch (PDOException $ex) {
                    // SQLSTATE[23xxx] - integrity constraint violation
                    if (!str_starts_with($ex->getCode(), '23')) {
                        throw $ex;
                    }
                }
            }

            $this->output->fwrite($line);
        }
    }

    private function parseOrder(string $data): ?array
    {
        $order = str_getcsv($data, separator: ';', escape: '\\');

        if (count($order) !== 3) {
            return null;
        }

        $order[0] = $this->parseInt($order[0], min_range: 1);
        $order[1] = $this->parseInt($order[1], min_range: 1);
        $order[2] = trim($order[2]);

        if (isset($order[0], $order[1], $order[2])) {
            return $order;
        }

        return null;
    }

    private function parseInt(string $data, int ...$options): ?int
    {
        return filter_var($data, FILTER_VALIDATE_INT, [
            'flags' => FILTER_NULL_ON_FAILURE,
            'options' => $options,
        ]);
    }
}
