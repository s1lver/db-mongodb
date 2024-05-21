<?php

declare(strict_types=1);

namespace Yiisoft\Db\MongoDb\Tests;

use PHPUnit\Framework\TestCase;
use Yiisoft\Db\MongoDb\Dsn;

class DsnTest extends TestCase
{
    /**
     * Simple stupid test
     */
    public function testDsn(): void
    {
        $this->assertSame(
            'mongodb://localhost:27017',
            (new Dsn('mongodb://localhost:27017'))->uri
        );
    }
}
